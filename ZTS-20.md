# ZTS-20: Zether Token Standard-20

**Version:** 1.0.0  
**Inspired By:** [ERC-20](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/) (Ethereum)  
**Status:** Draft

## Introduction

ZTS-20 (Zether Token Standard-20) is a fungible token standard designed for the Zether blockchain. Inspired by the widely adopted ERC-20 standard from Ethereum, ZTS-20 provides a clear, consistent set of rules and interfaces that ensure any token built on the Zether network can be easily integrated with wallets, exchanges, and decentralized applications.

By adhering to ZTS-20, token issuers and developers benefit from predictable token behavior, enhanced interoperability, and a shared ecosystem of tools and services. This standard serves as a foundational building block for broader adoption and innovation within the Zether ecosystem.

## Key Features

- **Fungibility:** All tokens created under ZTS-20 are interchangeable, carrying the same value and properties.
- **Interoperability:** Standardized methods and events allow straightforward integration with ecosystem tools, such as wallets, DEXs, payment processors, and governance platforms.
- **Simplicity:** Built on familiar patterns established by ERC-20, ensuring that developers experienced with Ethereum or other EVM-compatible chains can easily adapt.

## Interface and Requirements

ZTS-20 tokens MUST implement the following functions and events.  
**Note:** The syntax and data types may vary depending on the implementation language or smart contract framework.

### Required Functions

1. **`function name() external view returns (string)`**
   - Returns the name of the token.

2. **`function symbol() external view returns (string)`**
   - Returns the symbol of the token, e.g., "ZTS".

3. **`function decimals() external view returns (uint8)`**
   - Returns the number of decimal places the token uses. For example, if `decimals()` returns `18`, then `1` token is represented as `1 * 10^18` in the smallest unit.

4. **`function totalSupply() external view returns (uint256)`**
   - Returns the total amount of tokens in existence.

5. **`function balanceOf(address account) external view returns (uint256)`**
   - Returns the account balance of another account with address `account`.

6. **`function transfer(address to, uint256 amount) external returns (bool)`**
   - Transfers `amount` tokens from the caller’s account to the `to` address.
   - MUST revert if the caller does not have enough balance.
   - MUST emit a `Transfer` event.

7. **`function allowance(address owner, address spender) external view returns (uint256)`**
   - Returns the remaining number of tokens that `spender` is allowed to spend on behalf of `owner` through `transferFrom`.
   
8. **`function approve(address spender, uint256 amount) external returns (bool)`**
   - Sets `amount` as the allowance of `spender` over the caller’s tokens.
   - MUST emit an `Approval` event.

9. **`function transferFrom(address from, address to, uint256 amount) external returns (bool)`**
   - Moves `amount` tokens from `from` to `to` using the allowance mechanism.
   - `amount` is then deducted from the caller’s allowance.
   - MUST revert if `from` does not have enough tokens.
   - MUST revert if `caller` does not have sufficient allowance.
   - MUST emit a `Transfer` event.

### Required Events

1. **`event Transfer(address indexed from, address indexed to, uint256 value)`**
   - Emitted when `value` tokens are moved from one account to another.
   - `value` may be zero.

2. **`event Approval(address indexed owner, address indexed spender, uint256 value)`**
   - Emitted when the allowance of a `spender` for an `owner` is set by a call to `approve`.
   - `value` may be zero.

### Additional Recommendations

- **Metadata Extension:**  
  While `name()`, `symbol()`, and `decimals()` are optional in ERC-20, ZTS-20 strongly recommends their implementation to improve user experience and integration clarity.

- **Safe Arithmetic:**  
  Implementations should ensure operations like addition, subtraction, and multiplication are handled safely, reverting on arithmetic overflows.

- **Gas Efficiency:**  
  Consider optimizing for lower gas usage where possible, such as using events and calldata effectively, and employing efficient storage patterns.

## Rationale

ZTS-20 draws direct inspiration from the proven ERC-20 standard to provide a sense of familiarity and reliability to developers and users within the Zether ecosystem. By maintaining a close resemblance to ERC-20, existing tools, libraries, and dApps can be ported or integrated with minimal friction, accelerating ecosystem growth and innovation.

## Security Considerations

- **Reentrancy and Validation:**  
  Implementations must guard against reentrancy attacks, validate input parameters, and ensure all state changes are secure.
  
- **Allowance Race Condition:**  
  As with ERC-20, allowances should be used carefully. It is recommended to first set the spender’s allowance to zero and wait for transaction confirmation before setting a new allowance.

## Example Implementation

Below is a simplified example of how a ZTS-20 token might be implemented in Solidity (pseudocode):

```solidity
pragma solidity ^0.8.0;

contract ZTS20Token {
    string public name = "ZTS20 Token";
    string public symbol = "ZTS";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 _initialSupply) {
        balances[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balances[from] >= amount, "Insufficient balance");
        require(allowances[from][msg.sender] >= amount, "Allowance exceeded");
        
        allowances[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ZTS20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address who) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint tokens, address token, bytes calldata data) external;
}

contract ZTS20Token is ZTS20 {
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;
    
    string public name;
    string public symbol;
    uint8 public decimals;
    address public deployer;

    uint256 private _totalSupply;

    /**
     * @dev Constructor that initializes the token with customizable parameters.
     * @param _name The name of the token.
     * @param _symbol The symbol/ticker of the token.
     * @param _decimals The number of decimals the token uses.
     * @param _initialSupply The total supply of the token in whole tokens.
     *                       The contract will convert this to the smallest unit.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        deployer = msg.sender;
        _totalSupply = _initialSupply * (10 ** uint256(decimals));
        balances[deployer] = _totalSupply;
        emit Transfer(address(0), deployer, _totalSupply);
    }

    /**
     * @dev Returns the total token supply.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the account balance of another account with address `addr`.
     * @param addr The address of the account to query.
     */
    function balanceOf(address addr) public view override returns (uint256) {
        return balances[addr];
    }

    /**
     * @dev Returns the amount which `spender` is still allowed to withdraw from `owner`.
     * @param owner The address which owns the funds.
     * @param spender The address which will spend the funds.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowed[owner][spender];
    }

    /**
     * @dev Transfers `value` tokens to address `to`.
     * @param to The address to transfer to.
     * @param value The amount to be transferred in smallest units.
     */
    function transfer(address to, uint256 value) public override returns (bool) {
        require(value <= balances[msg.sender], "Insufficient balance.");
        require(to != address(0), "Cannot transfer to the zero address.");

        balances[msg.sender] -= value;
        balances[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Transfers multiple tokens to multiple addresses.
     * @param receivers The array of addresses to transfer to.
     * @param amounts The array of amounts to transfer in smallest units.
     */
    function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
        require(receivers.length == amounts.length, "Receivers and amounts length mismatch.");
        for (uint256 i = 0; i < receivers.length; i++) {
            transfer(receivers[i], amounts[i]);
        }
    }

    /**
     * @dev Allows `spender` to withdraw from your account multiple times, up to the `value` amount.
     * @param spender The address authorized to spend.
     * @param value The maximum amount they can spend in smallest units.
     */
    function approve(address spender, uint256 value) public override returns (bool) {
        require(spender != address(0), "Cannot approve the zero address.");
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfers `value` tokens from address `from` to address `to` using the allowance mechanism.
     * @param from The address you want to send tokens from.
     * @param to The address you want to transfer to.
     * @param value The amount of tokens to be transferred in smallest units.
     */
    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(value <= balances[from], "Insufficient balance.");
        require(value <= allowed[from][msg.sender], "Allowance exceeded.");
        require(to != address(0), "Cannot transfer to the zero address.");

        balances[from] -= value;
        balances[to] += value;
        allowed[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }

    /**
     * @dev Increases the amount of tokens that an owner allowed to a spender.
     * @param spender The address authorized to spend.
     * @param addedValue The amount of tokens to increase the allowance by in smallest units.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0), "Cannot increase allowance for the zero address.");
        allowed[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decreases the amount of tokens that an owner allowed to a spender.
     * @param spender The address authorized to spend.
     * @param subtractedValue The amount of tokens to decrease the allowance by in smallest units.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0), "Cannot decrease allowance for the zero address.");
        require(subtractedValue <= allowed[msg.sender][spender], "Decreased allowance below zero.");
        allowed[msg.sender][spender] -= subtractedValue;
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }
}

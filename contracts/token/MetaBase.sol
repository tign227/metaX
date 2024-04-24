// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interface/IERC20.sol";
import "./Ticket.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract MetaBase is IERC20, Ownable(msg.sender) {
    Ticket public ticket;
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    // ticket balances of each user
    mapping(address => uint256) public ticketBalance;
    uint256 public ticketThreshold = 100;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address ticket
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function ticketBalanceOf(
        address account
    ) external view returns (uint256) {
        return ticketBalance[account];
    }

    function setTicketThreshold(
        uint256 _threshold
    ) external onlyOwner {
        ticketThreshold = _threshold;
    }

    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(amount <= _balances[msg.sender], "Insufficient balance");
        if (amount >= ticketThreshold) {
            ticket.transferFrom(msg.sender , recipient, 1);
        }
        uint256 fee = amount / 10; // 10% fee
        uint256 transferAmount = amount - fee;

        _balances[msg.sender] -= amount;
        _balances[recipient] += transferAmount;
        _balances[address(this)] += fee; // fee goes to contract

        emit Transfer(msg.sender, recipient, transferAmount);
        emit Transfer(msg.sender, address(this), fee);

        return true;
    }
    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        if (amount >= ticketThreshold) {
            _mintTicket(account);
        }
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        require(amount <= _balances[account], "ERC20: burn amount exceeds balance");
        if (amount >= ticketThreshold && ticketBalance[msg.sender] > 0) {
            _burnTicket(account);
        }
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(amount <= _balances[sender], "Insufficient balance");
        require(
            amount <= _allowances[sender][msg.sender],
            "Allowance exceeded"
        );

        uint256 fee = amount / 10; // 10% fee
        uint256 transferAmount = amount - fee;

        if (amount >= ticketThreshold && ticketBalance[msg.sender] > 0) {
            ticket.transferFrom(sender, recipient, ticket.availableTicketId(sender));
        }

        _balances[sender] -= amount;
        _balances[recipient] += transferAmount;
        _balances[address(this)] += fee; // fee goes to contract
        _allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, transferAmount);
        emit Transfer(sender, address(this), fee);

        return true;
    }

    function _mintTicket(address account) internal {
        ticket.mintTicket(account);
        ticketBalance[account] = ticketBalance[account] + 1;
    }

    function _burnTicket(address account) internal {
        ticket.burnTicket(account);
        ticketBalance[account] = ticketBalance[account] - 1;
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Ticket.sol";
import "./MetaBase.sol";

contract MetaCoin is MetaBase {
    constructor(address _ticket) MetaBase("meteX Coin", "xToken", 18,  _ticket) {
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        require(_amount > 0, "Amount should be greater than 0");
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) public onlyOwner {
        require(_amount > 0, "Amount should be greater than 0");
        _burn(_from, _amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract MetaXToken is ERC20, Ownable(msg.sender) {
    string public constant NAME = "xToken";

    constructor() ERC20("metaX Token", "xToken") {
    }

    function mint(address _to, uint256 _amount) onlyOwner public {
        _mint(_to, _amount);
    }

    function burn(uint256 _amount) public {
        _burn(msg.sender, _amount);
    }
}

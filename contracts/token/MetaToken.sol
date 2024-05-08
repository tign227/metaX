// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract MetaToken is ERC20, Ownable(msg.sender) {
    string public constant NAME = "xToken";

    constructor() ERC20("metaX Token", "xToken") {
    }

    event MetaTokenMinted(address indexed to, uint256 amount);
    event MetaTokenBurned(address indexed from, uint256 amount);

    function mint(address _to, uint256 _amount) onlyOwner public {
        _mint(_to, _amount);
        emit MetaTokenMinted(_to, _amount);
    }

    function burn(address _from, uint256 _amount) public {
        _burn(_from, _amount);
        emit MetaTokenBurned(_from, _amount);
    }
}

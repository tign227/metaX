// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "../token/interfaces/IMechPet.sol";

contract MechPetMock is ERC721("mock MetaX Pet", "mXPet"), IMechPet {
    mapping(uint => uint) private _points;

    function setPoint(uint tokenId, uint points) external {
        _points[tokenId] = points;
    }

    function getPoint(uint tokenId) public view returns (uint256) {
        return _points[tokenId];
    }

    function mint(address to, uint tokenId) external {
        _mint(to, tokenId);
    }

    function growPet(uint256 amount) external {}
    function feedPet(uint256 amount) external {}
    function getPetIdOf(address owner) external view returns (uint256) {
        return 1000;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IMechPet is IERC721 {
    function getPoint(uint256 tokenId) external view returns (uint256);
    function growPet(uint256 amount) external;
    function feedPet(uint256 amount) external;
    function getPetIdOf(address owner) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Ticket is ERC721, Ownable {

    string private tokenUri = "ipfs://QmRB1Z8gknadsjegakSJYRU1AbmCtbrBjtDP8QDUhFMQQT" ;

    mapping(address => uint256[]) ids;

    uint256 tokenId;

    constructor() ERC721("metaX Ticket", "MXT") Ownable(msg.sender){

    }

    function assignTicket(address to) external onlyOwner {
        _safeMint(to, tokenId);
        ids[to].push(tokenId);
        tokenId++;
    }

    function allTicketOf(address owner) external view returns (uint256[] memory) {
        return ids[owner];
    }

    function tokenURI(uint tokenId) public view override returns (string memory){
        return tokenUri;
    }

    function changeTokenUri(string calldata _tokenUri) external onlyOwner {
        tokenUri = _tokenUri;
    }
}
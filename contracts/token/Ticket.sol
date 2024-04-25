// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Ticket is ERC721, Ownable {
    string public constant NAME = "Ticket";

    string private tokenUri =
        "ipfs://QmUQwF3tZ11HhnhFJaALyxR1MbMYWvwkTedrWYhknkSEAQ";

    mapping(address => uint256[]) ids;

    uint256 tokenId;

    constructor() ERC721("metaX Ticket", "xTicket") Ownable(msg.sender) {}

    function assignTicket(address to) external {
        _safeMint(to, tokenId);
        ids[to].push(tokenId);
        tokenId++;
    }

    function burnTiket(address from) external {

    }

    function allTicketOf(
        address owner
    ) external view returns (uint256[] memory) {
        return ids[owner];
    }

    function tokenURI(
        uint tokenId
    ) public view override returns (string memory) {
        return tokenUri;
    }

    function changeTokenUri(string calldata _tokenUri) external onlyOwner {
        tokenUri = _tokenUri;
    }
}

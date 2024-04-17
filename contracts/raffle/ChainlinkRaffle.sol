// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interface/IRaffle.sol";

contract ChainlinkRaffle is IRaffle {
    
    string public constant NAME = "ChainlinkRaffle";

    function getTicketId(
        uint256 length
    ) external view returns (uint256 tokenId) {
        return 1;
    }
}

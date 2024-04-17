// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interface/IRaffle.sol";

contract ChainlinkRaffle is IRaffle {

    function getTicketId(uint256 length) external view returns (uint256 tokenId) {
        return 1;
    }
}
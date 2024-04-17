// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRaffle {
    function getTicketId(uint length) external view returns (uint256 tokenId);
}
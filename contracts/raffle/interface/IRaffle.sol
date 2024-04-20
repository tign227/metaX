// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRaffle {
    function request(uint length) external;
    function getTicketId() external returns (uint ticketId); 
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;


contract RaffleMock {

    constructor() {}
    function request(uint length) external {
        // do nothing
    }
    function getTicketId() external pure returns (uint ticketId) {
        ticketId = 100;
    }
}
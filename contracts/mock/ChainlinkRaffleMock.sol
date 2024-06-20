// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../raffle/interface/IRaffle.sol";

contract ChainlinkRaffleMock is IRaffle {

    constructor() {}
    function request(uint length) external {
        // do nothing
    }
    function getTicketId() external pure returns (uint ticketId) {
        ticketId = 100;
    }
}
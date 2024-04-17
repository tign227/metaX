// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../raffle/interface/IRaffle.sol";
import '../token/Ticket.sol';

contract LuckyPick {
    string public constant NAME = "LuckPickc";
    IRaffle private raffle;
    Ticket private ticket;
    
    mapping(uint256 => address) registerTickets;

    uint256 ticketCount;
    uint256 keyCount;

    address private operator;

    modifier onlyOperator {
        require(msg.sender == address(operator), "LuckyPick: not operator");
        _;
    }

    constructor(IRaffle _raffle, Ticket _ticket) {
        raffle = _raffle;
        ticket = _ticket;
        operator = msg.sender;
    }

    function pickLuckyTicket() external onlyOperator returns (address, uint){
        uint256 tokenId = raffle.getTicketId(ticketCount);
        address owner = registerTickets[tokenId];
        _reset();
        return (owner, tokenId);
    }

    function register(address owner) external {
        uint[] memory ids = ticket.allTicketOf(owner);
        uint256 length = ids.length; 
        keyCount += 1;
        ticketCount += length;
        for (uint256 i = 0; i < length; ++i ) {
            registerTickets[ids[i]] = owner;
        }
    }

    function _reset() internal onlyOperator {
        for (uint256 i = 0; i < keyCount; ++i) {
            delete registerTickets[i];
        }
    }
}
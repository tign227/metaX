// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../raffle/interface/IRaffle.sol";
import "../token/MetaCoin.sol";

contract LuckyPick {
    string public constant NAME = "LuckyPick";

    MetaCoin private xToken;
    IRaffle private raffle;
    uint256 private ticketId;
    uint256 private ticketCount;
    uint256 private ticketPrice = 100;
    address private operator;
    mapping( uint256 =>Ticket ) tickets;
    bool public isPicking;
    mapping(address => bool) public hasClaimed;
    uint256 private winningTicketId;

    event TicketPurchased(address indexed buyer, uint256 indexed ticketPrice);
    event WinningTicket(uint256 indexed ticketId);

    struct Ticket {
        uint256 id;
        address owner;
        bool hasClaimed;
    }

    modifier onlyOperator {
        require(msg.sender == address(operator), "LuckyPick: not operator");
        _;
    }

    constructor(IRaffle _raffle, address _xToken ) {
        raffle = _raffle;
        xToken = MetaCoin(_xToken);
        operator = msg.sender;
    }

    function setTicketPrice(uint256 _ticketPrice) external onlyOperator {
        ticketPrice = _ticketPrice;
    }

    function buyTicket() external {
        require(!isPicking, "LuckyPick: already picking");
        require(xToken.balanceOf(msg.sender) >= ticketPrice, "Insufficient balance to buy tickets");
        xToken.transferFrom(msg.sender, address(this), ticketPrice);
        tickets[ticketId] = Ticket(ticketId, msg.sender, false);
        ticketId += 1;
        ticketCount += 1;
        emit TicketPurchased(msg.sender, ticketPrice);
    }

    function claim() external {
        require(isPicking, "LuckyPick: not picking");
        require(tickets[winningTicketId].owner == msg.sender, "LuckyPick: not owner of the winning ticket");
        require(!tickets[ticketId].hasClaimed, "LuckyPick: ticket has already been claimed");
        xToken.transfer(msg.sender, ticketPrice);
        tickets[ticketId].hasClaimed = true;
    }
    
    function startPick() external onlyOperator {
        require(!isPicking, "LuckyPick: already picking");
        isPicking = true;
        raffle.request(ticketCount);
    }

    function endPick() external onlyOperator {
        require(isPicking, "LuckyPick: not picking");
        isPicking = false;
        winningTicketId = raffle.getTicketId();
        emit WinningTicket(winningTicketId);
    }
}

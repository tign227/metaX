// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../raffle/interface/IRaffle.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract LuckyPick {
    string public constant NAME = "LuckyPick";

    uint256 private ticketId;
    uint256 private ticketCount;
    uint256 private ticketPrice = 10 ** 16;
    address private operator;
    mapping(uint256 => Ticket) private tickets;
    mapping(address => bool) private hasClaimed;
    mapping(address => bool) private hasBuyTicket;
    uint256 private winningTicketId;
    IERC20 private xToken;
    IRaffle private raffle;
    bool private isPicking;


    event PurchasedTicket(address indexed buyer, uint256 indexed ticketPrice);
    event EndPick(uint256 indexed ticketId);
    event StartPick(uint256 indexed ticketCount);
    event ClaimReward(address indexed owner);

    struct Ticket {
        uint256 id;
        address owner;
        bool hasClaimed;
    }

    modifier onlyOperator {
        require(msg.sender == address(operator), "LuckyPick: not operator");
        _;
    }

    constructor(address _xToken) {
        xToken = IERC20(_xToken);
        operator = msg.sender;
    }

    function setRaffle(IRaffle _raffle) external onlyOperator {
        raffle = _raffle;
    }

    function setTicketPrice(uint256 _ticketPrice) external onlyOperator {
        ticketPrice = _ticketPrice;
    }

    function buyTicket() external {
        require(!isPicking, "LuckyPick: already picking");
        address sender = msg.sender;
        xToken.transferFrom(sender, address(this), ticketPrice);
        hasBuyTicket[sender] = true;
        tickets[ticketId] = Ticket(ticketId, sender, false);
        ticketId += 1;
        ticketCount += 1;
        emit PurchasedTicket(sender, ticketPrice);
    }

    function claim() external {
        require(isPicking, "LuckyPick: not picking");
        address sender = msg.sender;
        require(tickets[winningTicketId].owner == sender, "LuckyPick: not owner");
        require(!tickets[ticketId].hasClaimed, "LuckyPick: already claimed");
        xToken.transfer(sender, ticketPrice);
        tickets[ticketId].hasClaimed = true;
        emit ClaimReward(sender);
    }

    function startPick() external onlyOperator {
        require(!isPicking, "LuckyPick: already picking");
        isPicking = true;
        raffle.request(ticketCount);
        emit StartPick(ticketCount);
    }

    function endPick() external onlyOperator {
        require(isPicking, "LuckyPick: not picking");
        isPicking = false;
        winningTicketId = raffle.getTicketId();
        //reset
        ticketId = 0;
        ticketCount = 0;
        emit EndPick(winningTicketId);
    }

    function getLuckyTicketId() external view returns (uint256) {
        require(!isPicking, "LuckyPick: not picking");
        require(hasBuyTicket[msg.sender], "LuckyPick: not buy ticket");
        return winningTicketId;
    }

    function getWinner() external view returns (address) {
        require(!isPicking, "LuckyPick: not picking");
        require(hasBuyTicket[msg.sender], "LuckyPick: not buy ticket");
        require(winningTicketId < ticketCount, "LuckyPick: not picked yet");
        return tickets[winningTicketId].owner;
    }

    function getTicketCount() external view returns (uint256) {
        return ticketCount;
    }
}

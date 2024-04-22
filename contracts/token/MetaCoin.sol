// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Ticket.sol";

contract MetaCoin is ERC20 {
    uint256 immutable TIKECT_THREADSHOD;

    Ticket private ticket;
    constructor(address _ticket) ERC20("meteX Coin", "xToken") {
        ticket = Ticket(_ticket);
        TIKECT_THREADSHOD = (decimals() * 5) / 10; //0.5 * 10 ** 18
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20) {
        require(address(from) != address(0), "from = 0");
        require(address(to) != address(0), "to = 0");
        super._update(from, to, value);
        if (value >= TIKECT_THREADSHOD) {
            ticket.assignTicket(to);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPriceFeed {
    function latestPrice(
        string memory _base,
        string memory _quote
    ) external returns (int);
}

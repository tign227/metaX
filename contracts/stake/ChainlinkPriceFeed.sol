// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IPriceFeed.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract ChainlinkPriceFeed is IPriceFeed, Ownable(msg.sender) {
    AggregatorV3Interface internal dataFeed;

    mapping(string => address) private feedAdddress;

    constructor() {}

    function latestPrice(
        string memory _base,
        string memory _quote
    ) external override returns (int) {
        string memory entry = string(abi.encodePacked(_base, "/", _quote));
        console.log(entry);
        dataFeed = AggregatorV3Interface(feedAdddress[entry]);
        (
            ,
            /* uint80 roundID */ int answer /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = dataFeed.latestRoundData();
        return answer;
    }

    function readFeedAddress(
        string[] memory entry,
        address[] memory dataFeedAddress
    ) external onlyOwner {
        uint256 len = entry.length;
        console.log(len);
        for (uint256 i = 0; i < len; i++) {
            feedAdddress[entry[i]] = dataFeedAddress[i];
            console.log("----", entry[i]);
            console.log(dataFeedAddress[i]);
        }
    }

    function getPriceFeedAddres(
        string calldata key
    ) external view returns (address) {
        return feedAdddress[key];
    }
}

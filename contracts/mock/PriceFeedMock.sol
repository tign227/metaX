// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import  "../stake/interfaces/IPriceFeed.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PriceFeedMock is IPriceFeed , Ownable (msg.sender){

        function latestPrice(
        string memory _base,
        string memory _quote
    ) external view returns (int) {
        return 1 * 10**18;
    }

    function readFeedAddress(
        string[] memory entry,
        address[] memory dataFeedAddress
    ) external onlyOwner {

    }
    
}
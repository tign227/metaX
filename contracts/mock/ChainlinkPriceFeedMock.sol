// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import  "../stake/interfaces/IPriceFeed.sol";
contract ChainlinkPriceFeedMock is IPriceFeed {

        function latestPrice(
        string memory _base,
        string memory _quote
    ) external returns (int) {
        return 1 * 10**18;
    }
    
}
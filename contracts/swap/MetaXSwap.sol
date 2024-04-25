// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "https://github.com/Uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/Uniswap/v2-periphery/contracts/interfaces/IUniswapV2Factory.sol";

contract MetaXSwap {
    //UNISWAP ADDRESS ON TESTNET
    address private constant UNISWAP_ROUTER_ADDRESS = 0x425141165d3DE9FEC831896C016617a52363b687;

    IUniswapV2Router02 private uniswapRouter;
    IUniswapV2Factory private uniswapFactory;

    constructor() {
        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
        uniswapFactory = IUniswapV2Factory(uniswapRouter.factory());
    }

    function exchangeForMetaXToken(address token, uint amountIn, address metaXToken) external {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = metaXToken;

        uniswapRouter.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            msg.sender,
            block.timestamp
        );
    }
}


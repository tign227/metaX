// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/TransferHelper.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/IUniswapV2Factory.sol";

contract MetaXLiquidity {
    //Sepolia's contract address
    address private constant FACTORY = 0xB7f907f7A9eBC822a80BD25E224be42Ce0A698A0;
    address private constant ROUTER = 0x425141165d3DE9FEC831896C016617a52363b687;

    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint _amountA,
        uint _amountB
    ) external {
        TransferHelper.safeTransferFrom(IERC20(_tokenA), msg.sender, address(this), _amountA);
        TransferHelper.safeTransferFrom(IERC20(_tokenB), msg.sender, address(this), _amountB);

        TransferHelper.safeApprove(IERC20(_tokenA), ROUTER, _amountA);
        TransferHelper.safeApprove(IERC20(_tokenB), ROUTER, _amountB);

        (uint amountA, uint amountB, uint liquidity) = IUniswapV2Router(ROUTER)
            .addLiquidity(
            _tokenA,
            _tokenB,
            _amountA,
            _amountB,
            1,
            1,
            address(this),
            block.timestamp
        );
    }

    function removeLiquidity(address _tokenA, address _tokenB) external {
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);

        uint liquidity = IERC20(pair).balanceOf(address(this));
        TransferHelper.safeApprove(IERC20(pair), ROUTER, liquidity);

        (uint amountA, uint amountB) = IUniswapV2Router(ROUTER).removeLiquidity(
            _tokenA,
            _tokenB,
            liquidity,
            1,
            1,
            address(this),
            block.timestamp
        );
    }
}

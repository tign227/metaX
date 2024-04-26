// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/TransferHelper.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/IUniswapV2Factory.sol";

contract MetaXLiquidity {
    //MAINNET's contract address
    address private constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

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

    function getPair(address _tokenA, address _tokenB) external view returns (address) {
        return IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);
    }
}

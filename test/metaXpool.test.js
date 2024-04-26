const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MetaXLiquidity", function () {

    let metaXLiquidity;
    let weth;
    let dai;

    beforeEach(async function () {
        const MetaXLiquidity = await ethers.getContractFactory("MetaXLiquidity");
        metaXLiquidity = await MetaXLiquidity.deploy();
        weth = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
        link = "0x514910771AF9Ca656af840dff83E8264EcF986CA";
    })

    it("Should get pair on fork mainnet", async function () {
        let liquidity = await metaXLiquidity.getPair(weth, link);
        console.log(liquidity);
    })



    //   // 测试添加流动性功能
    //   it("Should add liquidity to Uniswap", async function () {
    //     const MetaXLiquidity = await ethers.getContractFactory("MetaXLiquidity");
    //     const metaXLiquidity = await MetaXLiquidity.deploy("UNISWAP_ROUTER_ADDRESS"); // 请替换为实际的 Uniswap 路由器地址
    //
    //     await metaXLiquidity.deployed();
    //
    //     // 执行添加流动性操作
    //     const tx = await metaXLiquidity.addLiquidity(tokenA, tokenB, amountADesired, amountBDesired);
    //
    //     // 检查添加流动性操作是否成功
    //     await expect(tx).to.emit(metaXLiquidity, "LiquidityAdded")
    //       .withArgs(tokenA, tokenB, amountADesired, amountBDesired);
    //   });
    //
    //   // 测试代币交换功能
    //   it("Should swap tokens on Uniswap", async function () {
    //     const MetaXLiquidity = await ethers.getContractFactory("MetaXLiquidity");
    //     const metaXLiquidity = await MetaXLiquidity.deploy("UNISWAP_ROUTER_ADDRESS"); // 请替换为实际的 Uniswap 路由器地址
    //
    //     await metaXLiquidity.deployed();
    //
    //     // 执行代币交换操作
    //     const tx = await metaXLiquidity.swapTokens(tokenIn, tokenOut, amountIn, amountOutMin);
    //
    //     // 检查代币交换操作是否成功
    //     await expect(tx).to.emit(metaXLiquidity, "TokensSwapped")
    //       .withArgs(tokenIn, tokenOut, amountIn, amountOutMin);
    //   });
});

const { ethers, waffle } = require("hardhat");

const { PATHS, toJson, fromJson } = require('../util/files');
const assert = require('assert');
const { expect } = require("chai");


describe("ExpStake", function () {
    let metaXToken;
    let mechPet;
    let priceFeed;
    let deployer;
    let expStake

    beforeEach(async function () {
        [deployer, user] = await ethers.getSigners();

        //deploy metaXToken
        const MetaXToken = await ethers.getContractFactory("MetaXToken");
        metaXToken = await MetaXToken.deploy();

        //deploy pet
        const MechPet = await ethers.getContractFactory("MechPet");
        mechPet = await MechPet.deploy();

         //read pet mapping
                const jsonData = fromJson(PATHS.MAPPING, "entries.json");
                const upArray = jsonData.map((data) => data.up);
                const downArray = jsonData.map((data) => data.down);
                const lvArray = jsonData.map((data) => data.lv);
                const urlArray = jsonData.map((data) => data.url);
                await mechPet.readPetMapping(upArray, downArray, lvArray, urlArray);

        // deploy price feed
        const PriceFeed = await ethers.getContractFactory("ChainlinkPriceFeedMock");
        priceFeed = await PriceFeed.deploy();

        //free claim pet
        await mechPet.claimFreePet();

        //deploy exp stake
        const ExpStake = await ethers.getContractFactory("ExpStake");
        expStake = await ExpStake.deploy(metaXToken.target, mechPet.target, priceFeed.target);
        await metaXToken.mint(expStake.target, hre.ethers.parseUnits('1000000000000000', 18));
    });

    it("test stake", async function () {
        const amount = hre.ethers.parseEther("1");
        await expStake.connect(deployer).stake({ value: amount });

        const stakedBalance = await expStake.stakedETH(deployer.address);
        const lastClaimTime = await expStake.lastClaimTime(deployer.address);

        assert.equal(stakedBalance, amount, "Staked balance not equal to amount");
        assert.equal(lastClaimTime, (await ethers.provider.getBlock()).timestamp, "Last claim time not set correctly");

        const events = await expStake.queryFilter("StakeEth");
        assert.equal(events.length, 1, "Event not emitted");
        assert.equal(events[0].args.staker, deployer.address, "Event emitted by wrong address");
        assert.equal(events[0].args.amount.toString(), amount.toString(), "Event emitted with wrong amount");

    });

    it("should unstake ETH", async function () {
        //stake 99 eth ahead of time
        const amount = hre.ethers.parseEther("99");
        await expStake.connect(deployer).stake({ value: amount });

        //before unstake, the balace is 1 ether
        const initialBalance = await ethers.provider.getBalance(deployer.address);
        await expStake.connect(deployer).unstake();
        //after unstake, the balance is 100 eth
        const finalBalance = await ethers.provider.getBalance(deployer.address);
        //remaining balance should be 1 ether
        const stakedBalance = await expStake.stakedETH(deployer.address);
        //unstall all 99
        assert.equal(stakedBalance.toString(), "0", "Staked balance not reset");
        //balance should be 100 - 1 = 99
        console.log("ETH difference: ", finalBalance.toString() - initialBalance.toString())
    });

    it("should revert if no ETH staked", async function () {
        await expect(expStake.connect(deployer).unstake()).to.be.revertedWith("none staked");

    });

    it("test claim", async function () {
        //stake 100 eth ahead of time
        const amount = hre.ethers.parseEther("100");
        await expStake.connect(deployer).stake({ value: amount });


        await network.provider.send("evm_increaseTime", [1])
        await network.provider.send("evm_mine")

        //unstake all
        await expStake.connect(deployer).unstake();
        await expStake.connect(deployer).claim();

        //check balance
        const balanceOfETH = await ethers.provider.getBalance(deployer.address);
        const balanceOfToken = await metaXToken.balanceOf(deployer.address);
        const petId = await mechPet.getPetIdOf(deployer.address);
        const balaceOfExpOfPet = await mechPet.getExp(petId);
        console.log("ETH balance: ", balanceOfETH.toString());
        console.log("Token balance: ", balanceOfToken.toString());
        console.log("Exp of pet: ", balaceOfExpOfPet.toString());
    });
});

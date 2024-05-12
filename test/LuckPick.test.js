const { ethers } = require("hardhat");

const { expect } = require("chai");

describe("LuckyPick", function () {
  it("Should return the winning number", async function () {
    const [deployer] = await ethers.getSigners();
    const ChainlinkRaffleMock = await ethers.getContractFactory("ChainlinkRaffleMock");
    const chainlinkRaffleMock = await ChainlinkRaffleMock.deploy();

    const MetaToken = await ethers.getContractFactory("MetaXToken");
    const metaToken = await MetaToken.deploy();


    const LuckPick = await ethers.getContractFactory("LuckyPick");
    const luckPick = await LuckPick.deploy(metaToken.target);

    await luckPick.setTicketPrice(10);
    await metaToken.mint(deployer.address, 10);
    await metaToken.connect(deployer).approve(luckPick.target, 10);
    await luckPick.connect(deployer).buyTicket();
    await luckPick.setRaffle(chainlinkRaffleMock)
    const ticketCount = await luckPick.getTicketCount();
    expect(ticketCount).to.equal(1);
    await luckPick.startPick();
    await luckPick.endPick();
    const luckyTicketId = await luckPick.getLuckyTicketId();
    expect(luckyTicketId).to.equal(100);

  });
});

const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Ticket", function () {
  let Ticket;
  let ticket;
  let owner;
  let addr;

  beforeEach(async function () {
    Ticket = await ethers.getContractFactory("Ticket");
    [owner, addr] = await ethers.getSigners();

    ticket = await Ticket.deploy();
  });

  it("should assign a ticket to an address", async function () {
    await ticket.assignTicket(addr.address, 1);
    expect(await ticket.ownerOf(1)).to.equal(addr.address);
  });

  it("should return the correct token URI", async function () {
    const tokenUri = await ticket.tokenURI(1);
    expect(tokenUri).to.equal(
      "ipfs://QmRB1Z8gknadsjegakSJYRU1AbmCtbrBjtDP8QDUhFMQQT"
    );
  });

  it("should change the token URI", async function () {
    await ticket.changeTokenUri("newTokenUri");
    const updatedTokenUri = await ticket.tokenURI(1);
    expect(updatedTokenUri).to.equal("newTokenUri");
  });

  it("should only allow owner to change the token URI", async function () {
    await expect(ticket.connect(addr).changeTokenUri("newTokenUri")).to.be.reverted;
  });
});

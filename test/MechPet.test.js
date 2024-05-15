const { expect } = require("chai");
const { PATHS, toJson, fromJson } = require("../util/files");
describe("MechPet", function () {
  let mechPet;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    const MechPet = await ethers.getContractFactory("MechPet");
    mechPet = await MechPet.deploy();
    [owner, addr1, addr2] = await ethers.getSigners();
    //read pet mapping
    const jsonData = fromJson(PATHS.MAPPING, "entries.json");
    const upArray = jsonData.map((data) => data.up);
    const downArray = jsonData.map((data) => data.down);
    const lvArray = jsonData.map((data) => data.lv);
    const urlArray = jsonData.map((data) => data.url);
    await mechPet.readPetMapping(upArray, downArray, lvArray, urlArray);
  });

  it("Should mint a pet when claimed", async function () {
    await mechPet.connect(addr1).claimFreePet();
    expect(await mechPet.getPetIdOf(addr1.address)).to.equal(1);
  });

  it("Should not mint a pet if already claimed", async function () {
    await mechPet.connect(addr1).claimFreePet();
    await expect(mechPet.connect(addr1).claimFreePet()).to.be.revertedWith(
      "MechPet:already claimed"
    );
  });

  it("Should increase pet's experience when fed", async function () {
    await mechPet.connect(addr1).claimFreePet();
    const blockNumber = await ethers.provider.getBlockNumber();
    const block = await ethers.provider.getBlock(blockNumber);
    const blockTimestamp = block.timestamp;
    await expect(mechPet.connect(addr1).feedPet(150))
      .to.emit(mechPet, "FeedPet")
      .withArgs(blockTimestamp + 1, "Feed", 150);
    expect(await mechPet.getExp(1)).to.equal(150);
  });

  it("Should increase pet's point when grown", async function () {
    await mechPet.connect(addr1).claimFreePet();
    const blockNumber = await ethers.provider.getBlockNumber();
    const block = await ethers.provider.getBlock(blockNumber);
    const blockTimestamp = block.timestamp;
    await expect(mechPet.connect(addr1).growPet(50))
      .to.emit(mechPet, "GrowPet")
      .withArgs(blockTimestamp + 1, "Grow", 50);
    expect(await mechPet.getPoint(1)).to.equal(50);
  });

  it("Should return correct level of pet after feeding", async function () {
    await mechPet.connect(addr1).claimFreePet();
    await mechPet.connect(addr1).feedPet(10);
    const petId = await mechPet.getPetIdOf(addr1.address);
    expect(await mechPet.getLv(petId)).to.equal(0);
    await mechPet.connect(addr1).feedPet(90);
    expect(await mechPet.getLv(petId)).to.equal(1);
    await mechPet.connect(addr1).feedPet(100);
    expect(await mechPet.getLv(petId)).to.equal(1);
    await mechPet.connect(addr1).feedPet(400);
    expect(await mechPet.getLv(petId)).to.equal(3);
    await mechPet.connect(addr1).feedPet(1100);
    expect(await mechPet.getLv(petId)).to.equal(5);
  });

  it.skip("Should return correct URI for token", async function () {
    await mechPet.connect(addr1).claimFreePet();
    expect(await mechPet.tokenURI(1)).to.equal("ipfs:0");
  });

  it("Should revert if trying to feed or grow a non-existent pet", async function () {
    await expect(mechPet.connect(addr1).feedPet(100)).to.be.revertedWith(
      "MechPet:not mint"
    );
    await expect(mechPet.connect(addr1).growPet(50)).to.be.revertedWith(
      "MechPet:not mint"
    );
  });

  it("Should emit correct events", async function () {
    await mechPet.connect(addr1).claimFreePet();
    const blockNumber = await ethers.provider.getBlockNumber();
    const block = await ethers.provider.getBlock(blockNumber);
    const blockTimestamp = block.timestamp;
    await expect(mechPet.connect(addr1).feedPet(150))
      .to.emit(mechPet, "FeedPet")
      .withArgs(blockTimestamp + 1, "Feed", 150);
    await expect(mechPet.connect(addr1).growPet(50))
      .to.emit(mechPet, "GrowPet")
      .withArgs(blockTimestamp + 2, "Grow", 50);
  });

  it("Should emit hit cace events", async function () {
    const exp = 104;
    await mechPet.connect(addr1).claimFreePet();
    const petId1 = await mechPet.getPetIdOf(addr1.address);
    await expect(mechPet.connect(addr1).feedPet(exp))
      .to.emit(mechPet, "SearchPetEntry")
      .withArgs(petId1, 1);
    await mechPet.connect(addr2).claimFreePet();
    const petId2 = await mechPet.getPetIdOf(addr2.address);

    await expect(mechPet.connect(addr2).feedPet(exp))
      .to.emit(mechPet, "EntryCacheHit")
      .withArgs(petId2, exp);
  });
});

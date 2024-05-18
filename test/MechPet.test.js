const { expect } = require("chai");
const { PATHS, toJson, fromJson } = require("../util/files");
describe("MechPet", function () {
  let mechPet;
  let metaXToken;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    const MetaXToken = await ethers.getContractFactory("MetaXToken");
    metaXToken = await MetaXToken.deploy();

    const MechPet = await ethers.getContractFactory("MechPet");
    mechPet = await MechPet.deploy(metaXToken.target);

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
    await expect(mechPet.connect(addr1).feedPetWithX(150))
      .to.emit(mechPet, "FeedPet")
      .withArgs(blockTimestamp + 1, 150);
    expect(await mechPet.getExp(1)).to.equal(150);
  });

  it("Should increase pet's point when grown", async function () {
    await mechPet.connect(addr1).claimFreePet();
    const blockNumber = await ethers.provider.getBlockNumber();
    const block = await ethers.provider.getBlock(blockNumber);
    const blockTimestamp = block.timestamp;
    await expect(mechPet.connect(addr1).growPet(50))
      .to.emit(mechPet, "GrowPet")
      .withArgs(blockTimestamp + 1, 50);
    expect(await mechPet.getPoint(1)).to.equal(50);
  });

  it("Should return correct level of pet after feeding", async function () {
    await mechPet.connect(addr1).claimFreePet();
    await mechPet.connect(addr1).feedPetWithX(10);
    const petId = await mechPet.getPetIdOf(addr1.address);
    expect(await mechPet.getLv(petId)).to.equal(0);
    await mechPet.connect(addr1).feedPetWithX(90);
    expect(await mechPet.getLv(petId)).to.equal(1);
    await mechPet.connect(addr1).feedPetWithX(100);
    expect(await mechPet.getLv(petId)).to.equal(1);
    await mechPet.connect(addr1).feedPetWithX(400);
    expect(await mechPet.getLv(petId)).to.equal(3);
    await mechPet.connect(addr1).feedPetWithX(1100);
    expect(await mechPet.getLv(petId)).to.equal(5);
  });

  it.skip("Should return correct URI for token", async function () {
    await mechPet.connect(addr1).claimFreePet();
    expect(await mechPet.tokenURI(1)).to.equal("ipfs:0");
  });

  it("Should revert if trying to feed or grow a non-existent pet", async function () {
    await expect(mechPet.connect(addr1).feedPetWithX(100)).to.be.revertedWith(
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
    await expect(mechPet.connect(addr1).feedPetWithX(150))
      .to.emit(mechPet, "FeedPet")
      .withArgs(blockTimestamp + 1, 150);
    await expect(mechPet.connect(addr1).growPet(50))
      .to.emit(mechPet, "GrowPet")
      .withArgs(blockTimestamp + 2, 50);
  });

  it("Should emit hit cace events", async function () {
    const exp = 104;
    await mechPet.connect(addr1).claimFreePet();
    const petId1 = await mechPet.getPetIdOf(addr1.address);
    await expect(mechPet.connect(addr1).feedPetWithX(exp))
      .to.emit(mechPet, "SearchPetEntry")
      .withArgs(petId1, 1);
    await mechPet.connect(addr2).claimFreePet();
    const petId2 = await mechPet.getPetIdOf(addr2.address);

    await expect(mechPet.connect(addr2).feedPetWithX(exp))
      .to.emit(mechPet, "EntryCacheHit")
      .withArgs(petId2, exp);
  });

  it("should feed pet with food", async function () {
    await metaXToken.mint(addr1.address, 100);
    await mechPet.connect(addr1).claimFreePet();

    expect(await metaXToken.balanceOf(addr1.address)).to.equal(100);

    await metaXToken.connect(addr1).approve(mechPet.target, 50);

    await mechPet.connect(addr1).feedPetWithFood(50);

    expect(await metaXToken.balanceOf(addr1.address)).to.equal(50);
    expect(await metaXToken.balanceOf(mechPet.target)).to.equal(50);
  });

  it("should fail if not enough xToken", async function () {
    await mechPet.connect(addr1).claimFreePet();

    expect(await metaXToken.balanceOf(addr1.address)).to.equal(0);

    await expect(mechPet.connect(addr1).feedPetWithFood(50)).to.be.revertedWith(
      "MechPet:not enough xToken"
    );
  });
});

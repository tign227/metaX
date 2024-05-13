const { expect } = require("chai");
const { PATHS, toJson, fromJson } = require('../util/files');
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
        await mechPet.claimFreePet(addr1.address);
        expect(await mechPet.getPetIdOf(addr1.address)).to.equal(1);
    });

    it("Should not mint a pet if already claimed", async function () {
        await mechPet.claimFreePet(addr1.address);
        await expect(mechPet.claimFreePet(addr1.address)).to.be.revertedWith(
            "MechPet:already claimed"
        );
    });

    it("Should increase pet's experience when fed", async function () {
        await mechPet.claimFreePet(addr1.address);
        await mechPet.feedPet(1, 100);
        expect(await mechPet.getExp(1)).to.equal(100);
    });

    it("Should increase pet's point when grown", async function () {
        await mechPet.claimFreePet(addr1.address);
        await mechPet.growPet(1, 50);
        expect(await mechPet.getPoint(1)).to.equal(50);
    });

    it("Should return correct level of pet after feeding", async function () {
        await mechPet.claimFreePet(addr1.address);
        const petId = await mechPet.getPetIdOf(addr1.address);
        await mechPet.feedPet(petId, 10);
        expect(await mechPet.getLv(petId)).to.equal(0);
        await mechPet.feedPet(petId, 90);
        expect(await mechPet.getLv(petId)).to.equal(1);
        await mechPet.feedPet(petId, 100);
        expect(await mechPet.getLv(petId)).to.equal(1);
        await mechPet.feedPet(petId, 400);
        expect(await mechPet.getLv(petId)).to.equal(3);
        await mechPet.feedPet(petId, 1100);
        expect(await mechPet.getLv(petId)).to.equal(5);
    });

    it("Should return correct URI for token", async function () {
        await mechPet.claimFreePet(addr1.address);
        expect(await mechPet.tokenURI(1)).to.equal(
            "ipfs:0"
        );
    });

    it("Should revert if trying to feed or grow a non-existent pet", async function () {
        await expect(mechPet.feedPet(0, 100)).to.be.revertedWith(
            "MechPet:not mint"
        );
        await expect(mechPet.growPet(0, 50)).to.be.revertedWith("MechPet:not mint");
    });

    it("Should emit correct events", async function () {
        await mechPet.claimFreePet(addr1.address);
        await expect(mechPet.feedPet(1, 100))
            .to.emit(mechPet, "FeedPet")
            .withArgs(1, 100);
        await expect(mechPet.growPet(1, 50))
            .to.emit(mechPet, "GrowPet")
            .withArgs(1, 50);
    });

    it("Should emit hit cace events", async function () {
        const exp = 104;
        await mechPet.claimFreePet(addr1.address);
        const petId1 = await mechPet.getPetIdOf(addr1.address);
        await expect(mechPet.feedPet(petId1, exp))
            .to.emit(mechPet, "SearchPetEntry")
            .withArgs(petId1, 1);
        await mechPet.claimFreePet(addr2.address);
        const petId2 = await mechPet.getPetIdOf(addr2.address);

        await expect(mechPet.feedPet(petId2, exp))
            .to.emit(mechPet, "EntryCacheHit")
            .withArgs(petId2, exp);
    });
});

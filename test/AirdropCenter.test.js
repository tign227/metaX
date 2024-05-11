const {ethers} = require("hardhat");

const {expect} = require("chai");

describe("AirdropCenter", function () {
    let metaXToken;
    let mechPet;
    let testing;
    let rate = 10;
    let deployer;
    let other;

    beforeEach(async function () {
        metaXToken = await ethers.deployContract("MetaXToken");
        mechPet = await ethers.deployContract("MechPetMock");
        testing = await ethers.deployContract("AirdropCenter", [metaXToken.target, mechPet.target, rate]);
        [deployer, other] = await ethers.getSigners();
        await metaXToken.mint(testing.target, 10000);
    });

    it("test getter", async function () {
        expect(await testing.metaXToken()).to.eq(metaXToken.target);
        expect(await testing.mechPet()).to.eq(mechPet.target);
        expect(await testing.rate()).to.eq(rate);
        expect(await testing.owner()).to.eq(deployer);
    });

    it("test setter", async function () {
        await testing.setMetaXToken(other);
        expect(await testing.metaXToken()).to.eq(other);
        await expect(testing.connect(other).setMetaXToken(other)).to.be.revertedWithCustomError(testing, 'OwnableUnauthorizedAccount');

        await testing.setMechPet(other);
        expect(await testing.mechPet()).to.eq(other);
        await expect(testing.connect(other).setMechPet(other)).to.be.revertedWithCustomError(testing, 'OwnableUnauthorizedAccount');

        await testing.setRate(0);
        expect(await testing.rate()).to.eq(0);
        await expect(testing.connect(other).setRate(0)).to.be.revertedWithCustomError(testing, 'OwnableUnauthorizedAccount')
    });

    it("test emergencyWithdraw()", async function () {
        await expect(testing.connect(other).emergencyWithdraw()).to.be.revertedWithCustomError(testing, 'OwnableUnauthorizedAccount')

        await expect(testing.emergencyWithdraw()).to.changeTokenBalances(metaXToken, [testing.target, deployer], [-10000, 10000])
    });

    it("test claimAirdrop()", async function () {
        const TOKEN_ID = 1024;
        await mechPet.mint(other, TOKEN_ID);
        await mechPet.setPoint(TOKEN_ID, 5);
        expect(await mechPet.getPoint(TOKEN_ID)).to.eq(5);
        expect(await testing.pointsClaimed(TOKEN_ID)).to.eq(0);

        await expect(testing.claimAirdrop(TOKEN_ID)).to.be.revertedWith('no auth');
        await expect(testing.connect(other).claimAirdrop(TOKEN_ID)).to.changeTokenBalances(metaXToken, [testing.target, other], [-5 * rate, 5 * rate]);
        expect(await testing.pointsClaimed(TOKEN_ID)).to.eq(5);
        await expect(testing.connect(other).claimAirdrop(TOKEN_ID)).to.emit(testing, 'ClaimAirdrop').withArgs(other, TOKEN_ID, 0);

        // change points
        await mechPet.setPoint(TOKEN_ID, 5 + 2);
        await mechPet.connect(other).transferFrom(other, deployer, TOKEN_ID);
        await expect(testing.claimAirdrop(TOKEN_ID)).to.changeTokenBalances(metaXToken, [testing.target, deployer], [-2 * rate, 2 * rate]);
        expect(await testing.pointsClaimed(TOKEN_ID)).to.eq(5 + 2);
    });
});

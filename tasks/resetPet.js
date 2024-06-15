const { PATHS, toJson, fromJson } = require("../util/files");

task("metaX:resetPet", "reset pet contract of specific address")
.addParam("userAddress", "address of user to reset pet config")
.setAction(
  async (taskArgs, hre) => {
    const network = hre.network.name;
    const [deployer] = await hre.ethers.getSigners();
    console.log(`deployer ${deployer.address} on network ${network}`);
    const userAddress = taskArgs.userAddress;
    console.log(`Resetting pet config of ${userAddress}...`);

    // Compile contracts
    await hre.run("compile");
    console.log("Contracts compiled successfully.");

    const jsonnData = fromJson(PATHS.ADDRESS, `metaX.${network}.json`);
    const petAddress = jsonnData["addresses"]["mechPet"];
    console.log(`Pet address from json file : ${petAddress}`);
    const mechPet = await hre.ethers.getContractAt("MechPet", petAddress);

    await mechPet.reset(userAddress);
    console.log(`Pet config of ${userAddress} reset successfully.`);
  }
);
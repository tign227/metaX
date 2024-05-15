const { PATHS, toJson, fromJson } = require("../util/files");
const prompt = require("prompt-sync")();

task("metaX:appDeployer", "deploy contract of metaX application ").setAction(
  async (taskArgs, hre) => {
    const network = hre.network.name;
    const [deployer] = await hre.ethers.getSigners();
    console.log(`deployer ${deployer.address} on network ${network}`);

    if (network === "mainnet") {
      const confirm = prompt(
        "You are deploying on the mainnet. Do you want to continue? (yes/no): "
      );
      if (confirm.toLowerCase() !== "yes") {
        console.log("Deployment aborted.");
        return;
      }
    }

    // deploy token
    const MetaXToken = await hre.ethers.getContractFactory(
      "MetaXToken",
      deployer
    );
    const metaXToken = await MetaXToken.deploy();

    //deploy NFT
    const MechPet = await hre.ethers.getContractFactory("MechPet", deployer);
    const mechPet = await MechPet.deploy();
    const mechPetAddress = mechPet.target;
    await hre.run("configMechPet", { mechPetAddress });


    const json = {
      network: network,
      addresses: {
        metaXToken: metaXToken.target,
        mechPet: mechPet.target,
      },
    };

    toJson(PATHS.ADDRESS, json, `metaX.${network}.json`);
  }
);

subtask("configMechPet", "config mech pet mapping")
  .addParam("mechPetAddress", "The Mech Pet contract address")
  .setAction(async (taskArgs, hre) => {
    const { mechPetAddress } = taskArgs;
    const network = hre.network.name;
    const [deployer] = await hre.ethers.getSigners();
    console.log(
      `config mech pet mapping with${deployer.address} on network ${network}`
    );

    const mechPet = await hre.ethers.getContractAt(
      "MechPet",
      mechPetAddress,
      deployer
    );

    const jsonData = fromJson(PATHS.MAPPING, "entries.json");
    const upArray = jsonData.map((data) => data.up);
    const downArray = jsonData.map((data) => data.down);
    const lvArray = jsonData.map((data) => data.lv);
    const urlArray = jsonData.map((data) => data.url);

    await mechPet.readPetMapping(upArray, downArray, lvArray, urlArray);
  });

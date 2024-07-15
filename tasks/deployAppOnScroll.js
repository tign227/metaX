const { PATHS, toJson, fromJson } = require("../util/files");
const prompt = require("prompt-sync")();

task("metaX:deployOnScroll", "deploy all contracts of metaX application on scroll").setAction(
  async (taskArgs, hre) => {
    const network = hre.network.name;
    const [deployer] = await hre.ethers.getSigners();
    console.log(`deployer ${deployer.address} on network ${network}`);

    // Compile contracts
    await hre.run("compile");
    console.log("Contracts compiled successfully.");

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
    //mint xToken to deployer
    metaXToken.mint(deployer.address, hre.ethers.parseUnits("100000000", 18))

    //deploy NFT
    const MechPet = await hre.ethers.getContractFactory("MechPet", deployer);
    const mechPet = await MechPet.deploy(metaXToken.target);
    const mechPetAddress = mechPet.target;
    await hre.run("configMechPetOnScroll", { mechPetAddress });

    //deploy lucky pick
    const LuckyPick = await hre.ethers.getContractFactory(
      "LuckyPick",
      deployer
    );
    const luckyPick = await LuckyPick.deploy(metaXToken.target);

    //deploy raffle
    const Raffle = await hre.ethers.getContractFactory(
      "RaffleMock",
      deployer
    );
    const raffle = await Raffle.deploy();

    await luckyPick.setRaffle(raffle.target);

    //deploy price feed
    const PriceFeed = await hre.ethers.getContractFactory("PriceFeedMock");
    const priceFeed = await PriceFeed.deploy();

    //deploy exp stake
    const ExpStake = await hre.ethers.getContractFactory("ExpStake");
    const expStake = await ExpStake.deploy(
      metaXToken.target,
      mechPet.target,
      priceFeed.target
    );

    //mint metaX token to expStake
    await metaXToken.mint(
      expStake.target,
      hre.ethers.parseUnits("1000000000000000", 18)
    );

    const json = {
      network: network,
      addresses: {
        metaXToken: metaXToken.target,
        mechPet: mechPet.target,
        raffle: raffle.target,
        luckyPick: luckyPick.target,
        expStake: expStake.target,
        priceFeed: priceFeed.target,
      },
    };

    toJson(PATHS.ADDRESS, json, `metaXOnScroll.${network}.json`);
  }
);

subtask("configMechPetOnScroll", "config mech pet mapping")
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
    console.log("mech pet read mapping completed");
  });



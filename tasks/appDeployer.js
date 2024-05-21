const { PATHS, toJson, fromJson } = require("../util/files");
const prompt = require("prompt-sync")();

task("metaX:deploy", "deploy all contracts of metaX application  ").setAction(
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

    //deploy NFT
    const MechPet = await hre.ethers.getContractFactory("MechPet", deployer);
    const mechPet = await MechPet.deploy(metaXToken.target);
    const mechPetAddress = mechPet.target;
    await hre.run("configMechPet", { mechPetAddress });

    //deploy lucky pick
    const LuckyPick = await hre.ethers.getContractFactory(
      "LuckyPick",
      deployer
    );
    const luckyPick = await LuckyPick.deploy(metaXToken.target);

    //deploy chainlink raffle
    const vrfConfig = fromJson(PATHS.CONFIG, "vrf.json")[network];
    const ChainlinkRaffle = await hre.ethers.getContractFactory(
      "ChainlinkRaffle",
      deployer
    );
    const chainlinkRaffle = await ChainlinkRaffle.deploy(
      vrfConfig.callbackGasLimit,
      vrfConfig.requestConfirmations,
      vrfConfig.numWords,
      vrfConfig.linkAddress,
      vrfConfig.wrapperAddress,
    );

    await luckyPick.setRaffle(chainlinkRaffle.target);

    //deploy price feed
    const PriceFeed = await hre.ethers.getContractFactory("ChainlinkPriceFeed");
    const priceFeed = await PriceFeed.deploy();
    const priceFeedAddress = priceFeed.target;
    await hre.run("configPriceFeed", { priceFeedAddress });

    //deploy exp stake
    const ExpStake = await hre.ethers.getContractFactory("ExpStake");
    const expStake = await ExpStake.deploy(
      metaXToken.target,
      mechPet.target,
      priceFeed.target
    );

    //mint metaX token
    await metaXToken.mint(
      expStake.target,
      hre.ethers.parseUnits("1000000000000000", 18)
    );

    const json = {
      network: network,
      addresses: {
        metaXToken: metaXToken.target,
        mechPet: mechPet.target,
        chainlinkRaffle: chainlinkRaffle.target,
        luckyPick: luckyPick.target,
        expStake: expStake.target,
        priceFeed: priceFeed.target,
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
    console.log("mech pet read mapping completed");
  });

subtask("configPriceFeed", "config price feed")
  .addParam("priceFeedAddress", "The Price feed contract address")
  .setAction(async (taskArgs, hre) => {
    const { priceFeedAddress } = taskArgs;
    const network = hre.network.name;
    const [deployer] = await hre.ethers.getSigners();
    console.log(
      `config price feed with${deployer.address} on network ${network}`
    );

    const priceFeed = await hre.ethers.getContractAt(
      "ChainlinkPriceFeed",
      priceFeedAddress,
      deployer
    );
    //read oracle data
    const oracle = fromJson(PATHS.ORACLE, "dataFeed.json");
    let tokenPairs = [];
    let addresses = [];
    Object.keys(oracle[network]).forEach((key) => {
      tokenPairs.push(key);
      addresses.push(oracle[network][key]);
    });

    await priceFeed.readFeedAddress(tokenPairs, addresses);
    console.log("read price feed oracle data completed");
  });

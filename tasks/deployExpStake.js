const { PATHS, toJson, fromJson } = require("../util/files");

task("metaX:deployExpStake", "deploy exp stake").setAction(
  async (taskArgs, hre) => {
    const network = hre.network.name;
    const [deployer] = await hre.ethers.getSigners();
    console.log(`deployer ${deployer.address} on network ${network}`);

    //deploy mechpet
    const MechPet = await hre.ethers.getContractFactory("MechPet");
    const mechPet = await MechPet.deploy();

    //read pet mapping
    const jsonData = fromJson(PATHS.MAPPING, "entries.json");
    const upArray = jsonData.map((data) => data.up);
    const downArray = jsonData.map((data) => data.down);
    const lvArray = jsonData.map((data) => data.lv);
    const urlArray = jsonData.map((data) => data.url);
    await mechPet.readPetMapping(upArray, downArray, lvArray, urlArray);

    //deploy metaX token
    const MetaXToken = await hre.ethers.getContractFactory("MetaXToken");
    const metaXToken = await MetaXToken.deploy();

    //deploy price feed
    const PriceFeed = await hre.ethers.getContractFactory("ChainlinkPriceFeed");
    const priceFeed = await PriceFeed.deploy();

    //read oracle data
    const oracle = fromJson(PATHS.ORACLE, "dataFeed.json");
    let tokenPairs = [];
    let addresses = [];
    Object.keys(oracle[network]).forEach((key) => {
      tokenPairs.push(key);
      addresses.push(oracle[network][key]);
    });

    await priceFeed.connect(deployer).readFeedAddress(tokenPairs, addresses);

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
        mechPet: mechPet.target,
        metaXToken: metaXToken.target,
        priceFeed: priceFeed.target,
        expStake: expStake.target,
      },
    };

    toJson(PATHS.ADDRESS, json, `expStake.${network}.json`);
  }
);

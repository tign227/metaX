const { PATHS, toJson, fromJson } = require("../util/files");

task("metaX:deployPrceFeed", "deploy chainlink price feed").setAction(
    async (taskArgs, hre) => {
        const network = hre.network.name;
        const [deployer] = await hre.ethers.getSigners();
        console.log(`deployer ${deployer.address} on network ${network}`);

        const ChainlinkPriceFeed = await hre.ethers.getContractFactory(
            "ChainlinkPriceFeed"
        );
        const chainlinkPriceFeed = await ChainlinkPriceFeed.deploy();

        console.log(`ChainlinkPriceFeed address: ${chainlinkPriceFeed.target}`);

        const oracle = fromJson(PATHS.ORACLE, "dataFeed.json");
        let tokenPairs = [];
        let addresses = [];
        Object.keys(oracle[network]).forEach(key => {
            tokenPairs.push(key);
            console.log(network);
            console.log(key, oracle[network][key]);
            addresses.push(oracle[network][key]);
        });


        await chainlinkPriceFeed.connect(deployer).readFeedAddress(tokenPairs, addresses);

        const json = {
            network: network,
            addresses: {
                priceFeed: chainlinkPriceFeed.target,
            },
        };

        toJson(PATHS.ADDRESS, json, `chainlinkPriceFeed.${network}.json`);
        //yarn hardhat metaX:deployPrceFeed
    }
);

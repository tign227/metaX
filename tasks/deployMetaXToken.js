const {PATHS, toJson, fromJson} = require('../util/files');

task("metaX:deployMetaXToken", "deploy meta x token")
    .setAction(async (taskArgs, hre) => {
        const network = hre.network.name
        const [deployer] = await hre.ethers.getSigners()
        console.log(`deployer ${deployer.address} on network ${network}`)
        const MetaXToken = await hre.ethers.getContractFactory("MetaXToken", deployer);
        const metaXToken = await MetaXToken.deploy();
        console.log(`MetaXToken address: ${metaXToken.target}`)

        const json = {
            network: network, addresses: {
                metaXToken: metaXToken.target,
            }
        };

        toJson(PATHS.ADDRESS, json, `meta_x_token.${network}.json`);

        await metaXToken.mint(deployer.address, hre.ethers.parseUnits('100000000', 18));
    });

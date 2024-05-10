const {PATHS, toJson, fromJson} = require('../util/files');

task("metaX:deployLuckyPick", "deploy lucky pick and chainlink raffle")
    .setAction(async (taskArgs, hre) => {
        const network = hre.network.name
        const [deployer] = await hre.ethers.getSigners()
        console.log(`deployer ${deployer.address} on network ${network}`)

        const metaXTokenAddress = fromJson(PATHS.ADDRESS, `meta_x_token.${network}.json`).addresses.metaXToken;
        const LuckyPick = await hre.ethers.getContractFactory("LuckyPick", deployer);
        const luckyPick = await LuckyPick.deploy(metaXTokenAddress);

        console.log(`LuckyPick address: ${luckyPick.target}`)

        const vrfConfig = fromJson(PATHS.CONFIG, "vrf.json")[network];

        const ChainlinkRaffle = await hre.ethers.getContractFactory("ChainlinkRaffle", deployer);
        const chainlinkRaffle = await ChainlinkRaffle.deploy(
            vrfConfig.callbackGasLimit,
            vrfConfig.requestConfirmations,
            vrfConfig.numWords,
            vrfConfig.linkAddress,
            vrfConfig.wrapperAddress,
            luckyPick.target
        );
        console.log(`ChainlinkRaffle address: ${chainlinkRaffle.target}`)

        const json = {
            network: network, addresses: {
                luckyPick: luckyPick.target, chainlinkRaffle: chainlinkRaffle.target,
            }
        };

        toJson(PATHS.ADDRESS, json, `lucky_pick.${network}.json`);
        // set raffle address in lucky pick
        await luckyPick.setRaffle(chainlinkRaffle.target);
    });

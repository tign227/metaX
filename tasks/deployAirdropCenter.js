const {PATHS, toJson, fromJson} = require('../util/files');

task("metaX:deployAirdropCenter", "deploy airdrop center")
    .setAction(async (taskArgs, hre) => {
        const network = hre.network.name
        const [deployer] = await hre.ethers.getSigners()
        console.log(`deployer ${deployer.address} on network ${network}`)

        const metaXTokenAddress = fromJson(PATHS.ADDRESS, `meta_x_token.${network}.json`).addresses.metaXToken;
        const mechPetAddress = fromJson(PATHS.ADDRESS, `mech_pet.${network}.json`).addresses.mechPet;

        const AirdropCenter = await hre.ethers.getContractFactory("AirdropCenter", deployer);
        const airdropCenter = await AirdropCenter.deploy(metaXTokenAddress, mechPetAddress, hre.ethers.parseUnits('1', 18));
        console.log(`AirdropCenter address: ${airdropCenter.target}`)

        const json = {
            network: network, addresses: {
                airdropCenter: airdropCenter.target,
            }
        };

        toJson(PATHS.ADDRESS, json, `airdrop_center.${network}.json`);

        console.log(`constructor args:
            metaXToken: ${await airdropCenter.metaXToken()}
            mechPet: ${await airdropCenter.mechPet()}
            rate: ${await airdropCenter.rate()}`)
    });

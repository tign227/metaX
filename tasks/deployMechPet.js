const {PATHS, toJson, fromJson} = require('../util/files');

task("metaX:deployMechPet", "deploy mech x pet")
    .setAction(async (taskArgs, hre) => {
        const network = hre.network.name
        const [deployer] = await hre.ethers.getSigners()
        console.log(`deployer ${deployer.address} on network ${network}`)
        const MechPet = await hre.ethers.getContractFactory("MechPet", deployer);
        const mechPet = await MechPet.deploy();
        console.log(`MechPet address: ${mechPet.target}`)

        const json = {
            network: network, addresses: {
                mechPet: mechPet.target,
            }
        };

        toJson(PATHS.ADDRESS, json, `mech_pet.${network}.json`);
    });

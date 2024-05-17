const { PATHS, toJson, fromJson } = require("../util/files");

task("metaX:deployMechPet", "deploy mech x pet").setAction(
    async (taskArgs, hre) => {
        const network = hre.network.name;
        const [deployer] = await hre.ethers.getSigners();
        console.log(`deployer ${deployer.address} on network ${network}`);
        const MechPet = await hre.ethers.getContractFactory("MechPet", deployer);
        const mechPet = await MechPet.deploy();
        console.log(`MechPet address: ${mechPet.target}`);

        const jsonData = fromJson(PATHS.MAPPING, "entries.json");
        const upArray = jsonData.map((data) => data.up);
        const downArray = jsonData.map((data) => data.down);
        const lvArray = jsonData.map((data) => data.lv);
        const urlArray = jsonData.map((data) => data.url);
        console.log("Deploying mech pet mapping...");
        await mechPet.readPetMapping(upArray, downArray, lvArray, urlArray);
        console.log("Mech pet mapping deployed!");


        const TestDemo = await hre.ethers.getContractFactory("TestDemo", deployer);
        const testDemo = await TestDemo.deploy("Hello, world!");

        const json = {
            network: network,
            addresses: {
                mechPet: mechPet.target,
                testDemo: testDemo.target,
            },
        };

        toJson(PATHS.ADDRESS, json, `mech_pet.${network}.json`);
    }
);

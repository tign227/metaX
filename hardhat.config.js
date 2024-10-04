require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();


//tasks
require("./tasks/resetPet");
require("./tasks/neoDeploy");


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: {
        compilers: [{
            version: "0.8.20",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200,
                },
            }
        }]
    }, networks: {
        hardhat: {
            // forking: {
            //     url: `https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_MAINNET_API_KEY}`,
            //     accounts: [process.env.PRIVATE_KEY]
            // }
        }, sepolia: {
            url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.PRIVATE_KEY}`,
            // accounts: [process.env.PRIVATE_KEY]
        }, neox_t4: {
            url: "https://neoxt4seed1.ngd.network",
            accounts: ["0x3eefd59406c8d8b780a68235de1241078ef4b69105acb1f0510a05986cdea654"],
            gasPrice: 25000000000,
            saveDeployments: true,
        }, localhost: {
            url: "http://127.0.0.1:8545",
        }
    }
};
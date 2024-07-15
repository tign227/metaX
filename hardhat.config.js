require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();


//tasks
require("./tasks/resetPet");
require("./tasks/deployAppOnScroll");


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
            url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_SEPOLIA_API_KEY}`,
            accounts: [process.env.PRIVATE_KEY]
        }, scroll_sepolia: {
            url: "https://sepolia-rpc.scroll.io",
            accounts: [process.env.PRIVATE_KEY],
            gasPrice: 3500000000000,
            saveDeployments: true,
        }, localhost: {
            url: "http://127.0.0.1:8545",
        }
    }
};
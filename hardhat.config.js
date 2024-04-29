require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();


//tasks
require("./tasks/configAndDeployTicket")
require("./tasks/metaTokenFaucet")


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.24"
      },
      {
        version: "0.8.20"
      }
    ]
  },
  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_SEPOLIA_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
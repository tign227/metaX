const { PATHS, toJson, fromJson } = require('../util/files');
task("metaX:tokenFaucet", "meta token faucet")
  .setAction(
    async (taskArgs, hre) => {
      const networkName = hre.network.name;
      //deploy token
      const MetaToken = await ethers.getContractFactory("MetaToken");
      const metaToken = await MetaToken.deploy();
      //deploy faucet
      const MetaTokenFaucet = await ethers.getContractFactory("MetaTokenFaucet");
      const requestAmount = ethers.parseEther("1");
      const metaTokenFaucet = await MetaTokenFaucet.deploy(metaToken.target, requestAmount, 1);
      //mint tokens to faucet
      const amount = ethers.parseEther("1000000");
      await metaToken.mint(metaTokenFaucet.target, amount);
      const json = {
        network: networkName,
        addresses: {
          metaToken: metaToken.target,
          metaTokenFaucet: metaTokenFaucet.target,
        }
      };
      const fileName = "metaX.faucet." + networkName + ".json";
      toJson(PATHS.ADDRESS, json, fileName);
    }
  );

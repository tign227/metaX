
const { PATHS, toJson, fromJson } = require('../util/files');

task("metaX:configAndDeployTicket", "config and deploy Ticket")
  .setAction(
    async (taskArgs, hre) => {
      const networkName = hre.network.name;
      const vrfJson = fromJson(PATHS.CONFIG, "chainlink_vrf_config.json");
      const configValues = vrfJson[networkName];
      const callbackGasLimit = configValues.callbackGasLimit;
      const requestConfirmations = configValues.requestConfirmations;
      const numWords = configValues.numWords;
      const linkAddress = configValues.linkAddress;
      const wrapperAddress = configValues.wrapperAddress;
      const ChainlinkRaffle = await ethers.getContractFactory("ChainlinkRaffle");
      const chainlinkRaffle = await ChainlinkRaffle.deploy(callbackGasLimit, requestConfirmations, numWords, linkAddress, wrapperAddress);

      const Ticket = await ethers.getContractFactory("Ticket");
      const ticket = await Ticket.deploy();

      const LuckyPick = await ethers.getContractFactory("LuckyPick");
      const luckyPick = await LuckyPick.deploy(chainlinkRaffle, ticket);
      const json = {
        network: networkName,
        addresses: {
          ticket: ticket.target,
          raffle: chainlinkRaffle.target,
          luckyPick: luckyPick.target
        }
      };

      const fileName = "metaX." + networkName + ".json";
      toJson(PATHS.ADDRESS, json, fileName);
    }
  );

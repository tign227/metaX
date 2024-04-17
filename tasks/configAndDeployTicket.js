
const { PATHS, toJson, fromJson } = require('../util/files');

task("metaX:configAndDeployTicket", "config and deploy Ticket")
  .setAction(
    async (taskArgs, hre) => {
      const Ticket = await ethers.getContractFactory("Ticket");
      const ticket = await Ticket.deploy();

      const ChainlinkRaffle = await ethers.getContractFactory("ChainlinkRaffle");
      const chainlinkRaffle = await ChainlinkRaffle.deploy();

      const LuckyPick = await ethers.getContractFactory("LuckyPick");
      const luckyPick = await LuckyPick.deploy(chainlinkRaffle, ticket);

      const networkName = hre.network.name;

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

      const vrfJson = fromJson(PATHS.CONFIG, "chainlink_vrf_config.json");

    }
  );

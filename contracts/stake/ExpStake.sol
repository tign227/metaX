//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IStake.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../token/interfaces/IMechPet.sol";
import  "./interfaces/IPriceFeed.sol"

contract ExpStake is IStake {

    IMechPet private mechPet;
    IPriceFeed private priceFeed;
    IERC20 private xToken;

    uint256 private expPerDay = 20;

    mapping(address => uint256) private stakes;
    mapping(address => uint256) private rewards;
    mapping(address => uint256) private exps;

    constructor(address _xToken,address _pet, address _priceFeed) {
        xToken = IERC20(_xToken);
        mechPet = IMechPet(_pet);
        priceFeed = IPriceFeed(_priceFeed);
    }

    function stake() external override {
        msg.sender.call{value: msg.value}("");
        stakes[msg.sender] += msg.value;

        string memory entry = string(abi.encodePacked("ETH", "/", "USD"));
        uint256 price = priceFeed.getPrice(entry);
        uint usdAmount = price * msg.value / 1e13;
        rewards[msg.sender] += usdAmount;
    }

    function unstake() external override {
        require(stakes[msg.sender] > 0, "ExpStake: No enough ETH");
        address(this).call{value: stakes[msg.sender]}("");
        stakes[msg.sender]   = 0;
    }

    function claim() external {
        require(rewards[msg.sender] > 0, "No rewards found");
        xToken.mint(msg.sender, rewards[msg.sender]);
        rewards[msg.sender] = 0;
    }
}

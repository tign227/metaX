//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IStake.sol";
import "../token/interfaces/IMechPet.sol";
import "./interfaces/IPriceFeed.sol";

abstract contract Stake is IStake {
    IMechPet public mechPet;
    IPriceFeed public priceFeed;
    IERC20 public xToken;

    mapping(address => uint) public stakedETH;
    mapping(address => uint) public lastClaimTime;
    mapping(address => uint) public rewardTokenAmounts;
    mapping(address => uint) public rewardAmounts;

    event StakeEth(address indexed staker, uint amount);
    event UnstakeEth(address indexed withdrawer, uint amount);

    constructor(address xTokenAddress, address mechPetAddress, address priceFeedAddress) {
        xToken = IERC20(xTokenAddress);
        mechPet = IMechPet(mechPetAddress);
        priceFeed = IPriceFeed(priceFeedAddress);
    }

    // 1 xToken per second
    function xTokenPerDay() internal virtual returns (uint) {
        return 1 days * 10 ** 18;
    }

    function rewardPerDay() internal virtual returns (uint);

    function NAME() external virtual returns (string memory);

    function claim() external virtual;

    function stake() external payable virtual {
        uint value = msg.value;
        address sender = msg.sender;
        require(value != 0, "no eth");
        lastClaimTime[sender] = block.timestamp;

        unchecked{
            stakedETH[sender] += value;
        }

        emit StakeEth(sender, value);
    }

    function unstake() external virtual {
        address sender = msg.sender;
        uint amount = stakedETH[sender];
        require(amount != 0, "none staked");
        delete stakedETH[sender];
        payable(sender).transfer(amount);
        emit UnstakeEth(sender, amount);
    }

    function _update(address staker) internal {
        uint currentTimeStamp = block.timestamp;
        uint elapsedTime = currentTimeStamp - lastClaimTime[staker];
        lastClaimTime[staker] = currentTimeStamp;

        // reward token
        uint xTokenAmount = (elapsedTime * xTokenPerDay()) / 1 days;
        int price = priceFeed.latestPrice("ETH", "USD");
        uint tokenReward = (xTokenAmount * uint256(price)) / 10 ** 18;
        rewardTokenAmounts[staker] += tokenReward;
        // reward
        rewardAmounts[staker] += (elapsedTime * rewardPerDay()) / 1 days;
    }

    function getReward() external returns (uint, uint) {
        address sender = msg.sender;
        _update(sender);
        return (rewardTokenAmounts[sender], rewardAmounts[sender]);
    }
}

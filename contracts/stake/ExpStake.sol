//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Stake} from "./Stake.sol";

contract ExpStake is Stake {
    constructor(
        address xTokenAddress,
        address mechPetAddress,
        address priceFeedAddress
    ) Stake(xTokenAddress, mechPetAddress, priceFeedAddress){}

    string public override NAME = "ExpStake";

    // 1 exp per second
    function rewardPerDay() internal override pure returns (uint){
        return 1 days;
    }

    function claim() external override {
        address sender = msg.sender;
        _update(sender);
        uint rewardTokenAmount = rewardTokenAmounts[sender];
        uint rewardAmount = rewardAmounts[sender];
        require(rewardTokenAmount != 0, "No rewards Token");
        require(rewardAmount != 0, "No rewards Exp");
        delete rewardTokenAmounts[sender];
        delete rewardAmounts[sender];
        xToken.transfer(sender, rewardTokenAmount);
        emit RewardClaimed(sender, rewardTokenAmount);
    }
}

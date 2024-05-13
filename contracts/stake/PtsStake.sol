//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Stake} from "./Stake.sol";

contract PtsStake is Stake {
    constructor(
        address xTokenAddress,
        address mechPetAddress,
        address priceFeedAddress
    ) Stake(xTokenAddress, mechPetAddress, priceFeedAddress){}

    string public override NAME = "PtsStake";

    // 120 points per day
    function rewardPerDay() internal override pure returns (uint){
        return 120;
    }

    function claim() external override {
        address sender = msg.sender;
        _update(sender);
        uint rewardTokenAmount = rewardTokenAmounts[sender];
        uint rewardAmount = rewardAmounts[sender];
        require(rewardTokenAmount != 0, "No rewards Token");
        require(rewardAmount != 0, "No rewards Exp");

        uint petId = mechPet.getPetIdOf(sender);
        mechPet.growPet(petId, rewardAmount);
        xToken.transfer(sender, rewardTokenAmount);
        emit RewardClaimed(sender, rewardTokenAmount);
    }
}
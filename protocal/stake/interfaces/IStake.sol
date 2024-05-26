//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IStake {
    event RewardClaimed(address indexed staker, uint amount);

    function stake() external payable;

    function unstake() external;

    function claim() external;
}

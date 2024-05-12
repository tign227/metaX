//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IStake {
    function stake() external payable;
    function unstake() external;
    function claim() external;
}

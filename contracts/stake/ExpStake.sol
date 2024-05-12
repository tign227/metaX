//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IStake.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../token/interfaces/IMechPet.sol";
import "./interfaces/IPriceFeed.sol";

contract ExpStake is IStake {
    string public constant NAME = "ExpStake";

    IMechPet private mechPet;
    IPriceFeed private priceFeed;
    IERC20 private xToken;

    //1 exp per second
    uint256 private expPerDay = 86400;
    //1 xToken per second
    uint256 private xTokenPerDay = 86400 * 10 ** 18;
    uint256 public constant secondsPerDay = 86400;

    mapping(address => uint256) public stakedETH;
    mapping(address => uint256) public rewardTokens;
    mapping(address => uint256) public rewardExps;
    mapping(address => uint256) public lastClaimTime;

    event Staked(address indexed staker, uint256 amount);
    event RewardClaimed(address indexed staker, uint256 amount);

    constructor(address _xToken, address _pet, address _priceFeed) {
        xToken = IERC20(_xToken);
        mechPet = IMechPet(_pet);
        priceFeed = IPriceFeed(_priceFeed);
    }

    function stake() external payable {
        require(msg.value > 0, "Cannot stake 0 ETH");
        stakedETH[msg.sender] += msg.value;
        lastClaimTime[msg.sender] = block.timestamp;
        emit Staked(msg.sender, msg.value);
    }

    function claim() external {
        _update(msg.sender);
        require(rewardTokens[msg.sender] > 0, "No rewards Token");
        require(rewardExps[msg.sender] > 0, "No rewards Exp");
        lastClaimTime[msg.sender] = block.timestamp;

        xToken.transfer(msg.sender, rewardTokens[msg.sender]);
        uint256 petId = mechPet.getPetIdOf(msg.sender);
        mechPet.feedPet(petId, rewardExps[msg.sender]);
        emit RewardClaimed(msg.sender, rewardTokens[msg.sender]);
    }

    function _updateReward(address staker) internal {
        uint256 elapsedTime = block.timestamp - lastClaimTime[staker];
        uint256 reward = (elapsedTime * xTokenPerDay) / secondsPerDay;
        int price = priceFeed.latestPrice("ETH", "USD");
        uint256 tokenReward = (reward * uint256(price)) / 10 ** 18;
        rewardTokens[staker] += tokenReward;
    }

    function _updateExp(address staker) internal {
        uint256 elapsedTime = block.timestamp - lastClaimTime[staker];
        uint256 exp = (elapsedTime * expPerDay) / secondsPerDay;
        rewardExps[staker] += exp;
    }

    function unstake() external {
        uint256 amount = stakedETH[msg.sender];
        require(amount > 0, "No ETH staked");
        stakedETH[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function getReward() external returns (uint256, uint256) {
        _update(msg.sender);
        return (rewardTokens[msg.sender], rewardExps[msg.sender]);
    }

    function _update(address staker) internal {
        _updateReward(msg.sender);
        _updateExp(msg.sender);
        lastClaimTime[staker] = block.timestamp;
    }
}

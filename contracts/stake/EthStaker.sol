//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract EthStaker {
    mapping(address => uint) public stakedETH;
    mapping(address => uint) public lastClaimTime;

    event StakeEth(address indexed staker, uint amount);
    event UnstakeEth(address indexed withdrawer, uint amount);

    function NAME() external virtual returns (string memory);

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
}

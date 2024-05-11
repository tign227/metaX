// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IMechPet} from "../token/interfaces/IMechPet.sol";

contract AirdropCenter is Ownable {
    IERC20 public metaXToken;
    IMechPet public mechPet;

    // key: token id of mechPet value: token amount has been claimed
    mapping(uint => uint) public claimed;

    event ClaimAirdrop(address claimer, uint tokenId, uint amount);

    constructor(
        IERC20 metaXToken_,
        IMechPet mechPet_
    )
    Ownable(msg.sender)
    {
        metaXToken = metaXToken_;
        mechPet = mechPet_;
    }

    function claimAirdrop(uint tokenId) external {
        address sender = msg.sender;
        require(mechPet.ownerOf(tokenId) == sender, "no auth");
        uint point = mechPet.getPoint(tokenId);
        uint amountToAirdrop = point - claimed[tokenId];
        claimed[tokenId] = point;

        metaXToken.transfer(sender, amountToAirdrop);
        emit ClaimAirdrop(sender, tokenId, amountToAirdrop);
    }

    function emergencyWithdraw() external onlyOwner {
        metaXToken.transfer(
            owner(),
            metaXToken.balanceOf(address(this))
        );
    }

    function setMetaXToken(IERC20 newMetaXToken) external onlyOwner {
        metaXToken = newMetaXToken;
    }

    function setMechPet(IMechPet newMechPet) external onlyOwner {
        mechPet = newMechPet;
    }
}

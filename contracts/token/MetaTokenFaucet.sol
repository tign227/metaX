// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MetaToken.sol";
/**
 * @title Faucet for the Meta Token
 */
contract MetaTokenFaucet is Ownable(msg.sender) {
    // Token
    MetaToken public token;

    // Amount of token sent to sender for a request
    uint256 public requestAmount;

    // Amount of time a sender must wait between requests
    uint256 public requestWait;

    // sender => timestamp at which sender can make another request
    mapping(address => uint256) public nextValidRequest;

    // Whitelist addresses that can bypass faucet request rate limit
    mapping(address => bool) public isWhitelisted;

    // Checks if a request is valid (sender is whitelisted or has waited the rate limit time)
    modifier validRequest() {
        require(isWhitelisted[msg.sender] || block.timestamp >= nextValidRequest[msg.sender]);
        _;
    }

    event Request(address indexed to, uint256 amount);

    constructor(
        address _token,
        uint256 _requestAmount,
        uint256 _requestWait
    ) {
        token = MetaToken(_token);
        requestAmount = _requestAmount;
        requestWait = _requestWait;
    }


    function addToWhitelist(address _addr) external onlyOwner {
        isWhitelisted[_addr] = true;
    }

    function removeFromWhitelist(address _addr) external onlyOwner {
        isWhitelisted[_addr] = false;
    }

    function request() external validRequest {
        if (!isWhitelisted[msg.sender]) {
            nextValidRequest[msg.sender] = block.timestamp + requestWait * 1 hours;
        }

        token.transfer(msg.sender, requestAmount);

        emit Request(msg.sender, requestAmount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interface/IRaffle.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFV2WrapperConsumerBase.sol";

contract ChainlinkRaffle is IRaffle, Ownable, VRFV2WrapperConsumerBase {
    string public constant NAME = "ChainlinkRaffle";

    event RequestSent(uint256 indexed requestId, uint32 indexed numWords);
    event RequestFulfilled(
        uint256 indexed requestId,
        uint256[] indexed randomWords,
        uint256 indexed payment
    );

    struct RequestStatus {
        uint256 linkAmount;
        bool fulfilled;
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus)
        public requets; /* requestId --> requestStatus */

    uint256 public lastRequestId;
    uint32 public callbackGasLimit;
    uint16 public requestConfirmations;
    uint32 public numWords;
    uint256 public length;
    address public linkAddress;
    address public wrapperAddress;

    constructor(
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations,
        uint32 _numWords,
        address _linkAddress,
        address _wrapperAddress
    )
        Ownable(msg.sender)
        VRFV2WrapperConsumerBase(_linkAddress, _wrapperAddress)
    {
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = _requestConfirmations;
        numWords = _numWords;
    }

    function request(uint256 length) external onlyOwner {
        _requestRandomWords(length);
    }

    function getTicketId() external view onlyOwner returns (uint ticketId) {
        RequestStatus memory status = requets[lastRequestId];
        require(status.fulfilled, "ChainlinkRaffle:not fulfilled");
        return status.randomWords[0] % length;
    }

    function _requestRandomWords(
        uint256 _length
    ) internal returns (uint256 requestId) {
        requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
        requets[requestId] = RequestStatus({
            linkAmount: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWords: new uint256[](0),
            fulfilled: false
        });
        lastRequestId = requestId;
        length = _length;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(requets[_requestId].linkAmount > 0, "ChainlinkRaffle:link not enough");
        requets[_requestId].fulfilled = true;
        requets[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(
            _requestId,
            _randomWords,
            requets[_requestId].linkAmount
        );
    }

    function getRequestStatus(
        uint256 _requestId
    )
        external
        view
        returns (
            uint256 linkAmount,
            bool fulfilled,
            uint256[] memory randomWords
        )
    {
        require(requets[_requestId].linkAmount > 0, "ChainlinkRaffle:insufficient funds");
        RequestStatus memory request = requets[_requestId];
        return (request.linkAmount, request.fulfilled, request.randomWords);
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(linkAddress);
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "ChainlinkRaffle:Unable to transfer"
        );
    }
}

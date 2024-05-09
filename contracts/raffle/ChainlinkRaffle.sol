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

    mapping(uint256 => RequestStatus) public requests; /* requestId --> requestStatus */
    mapping(address => bool) public reqAuths;

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
        address _wrapperAddress,
        address _reqAuth
    )
    Ownable(msg.sender)
    VRFV2WrapperConsumerBase(_linkAddress, _wrapperAddress)
    {
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = _requestConfirmations;
        numWords = _numWords;
        reqAuths[_reqAuth] = true;
    }

    function request(uint256 len) external {
        require(reqAuths[msg.sender], "no auth");
        _requestRandomWords(len);
    }

    function getTicketId() external view returns (uint ticketId) {
        RequestStatus memory status = requests[lastRequestId];
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
        requests[requestId] = RequestStatus({
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
        require(requests[_requestId].linkAmount > 0, "ChainlinkRaffle:link not enough");
        requests[_requestId].fulfilled = true;
        requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(
            _requestId,
            _randomWords,
            requests[_requestId].linkAmount
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
        require(requests[_requestId].linkAmount != 0, "ChainlinkRaffle:insufficient funds");
        RequestStatus memory req = requests[_requestId];
        return (req.linkAmount, req.fulfilled, req.randomWords);
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(linkAddress);
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "ChainlinkRaffle:Unable to transfer"
        );
    }
}

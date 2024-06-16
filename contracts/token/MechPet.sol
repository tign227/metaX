// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IMechPet.sol";

contract MechPet is ERC721URIStorage, IMechPet, Ownable(msg.sender) {
    string public constant NAME = "xPet";

    IERC20 private xToken;

    //feed with X only once every 24 hours
    uint256 private feedWait = 24;

    constructor(address xTokenAddress) ERC721("metaX Pet", "xPet") {
        xToken = IERC20(xTokenAddress);
    }

    //tokenId => PetData
    mapping(uint256 => PetData) private datas;
    PetEntry[] private entrys;
    //exp => entry
    mapping(uint256 => PetEntry) private extrysCached;
    //address => tokenId
    mapping(address => uint256) private petIdOf;
    // tokenId => next valid feed with X
    mapping(uint256 => uint256) public nextValidFeedWithX;
    //petId
    uint256 private petId = 1;

    struct PetEntry {
        uint256 up;
        uint256 down;
        uint256 lv;
        string uri;
    }

    struct PetData {
        uint256 lv;
        uint256 exp;
        uint256 point;
        string uri;
        PetType petType;
    }

    enum PetType {
        NULL,
        CAT,
        DOG
    }

    event FeedPet(uint256 indexed timestamp, uint256 indexed amount);
    event EntryCacheHit(uint256 indexed tokenId, uint256 indexed exp);
    event SearchPetEntry(uint256 indexed tokenId, uint256 indexed lv);
    event ReadPetMapping(uint256 indexed len);
    event GrowPet(uint256 indexed timestamp, uint256 indexed amount);

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(tokenId >= 1, "MechPet:not mint");
        return _fullURI(tokenId);
    }

    function _fullURI(uint256 tokenId) internal view returns (string memory url) {
        PetData memory data = datas[tokenId];
        string memory baseURI = data.uri;
        uint256 tokenType = uint256(data.petType);
        url = string(abi.encodePacked(baseURI, "/",  tokenType, "/", data.lv));

    }

    function claimFreePet(PetType petType) external {
        require(petIdOf[msg.sender] == 0, "MechPet:already claimed");
        _claim(msg.sender, petType);
    }

    function _claim(address to, PetType petType) internal {
        _safeMint(to, petId);
        _setTokenURI(petId, entrys[0].uri);
        datas[petId] = PetData(0, 0, 0, entrys[0].uri, petType);
        petIdOf[to] = petId;
        petId++;
    }

    function feedPetWithFood(uint256 amount, uint exp) external {
        require(xToken.balanceOf(msg.sender) >= amount, "MechPet:not enough xToken");
        xToken.transferFrom(msg.sender, address(this), amount);
        _feedPet(exp);
    }

    function feedPetWithX(uint256 amount) external {
        require(nextValidFeedWithX[petIdOf[msg.sender]] == 0 || block.timestamp >= nextValidFeedWithX[petIdOf[msg.sender]], "MechPet:less than one day");
        nextValidFeedWithX[petIdOf[msg.sender]] = block.timestamp + feedWait * 1 hours;
        _feedPet(amount);
    }

    function _feedPet(uint256 amount) internal {
        uint256 tokenId = petIdOf[msg.sender];
        require(tokenId >= 1, "MechPet:not mint");
        datas[tokenId].exp += amount;
        emit FeedPet(block.timestamp, amount);
        _findLv(datas[tokenId].exp, tokenId);
        _setTokenURI(tokenId, _fullURI(tokenId));
    }

    function growPet(uint256 amount) external {
        uint256 tokenId = petIdOf[msg.sender];
        require(tokenId >= 1, "MechPet:not mint");
        datas[tokenId].point += amount;
        emit GrowPet(block.timestamp, amount);
    }

    function withdrawXToken(uint256 amount) external onlyOwner {
        require(xToken.balanceOf(address(this)) >= amount, "MechPet:not enough xToken");
        xToken.transfer(msg.sender, amount);
    }

    function withdrawAllXToken() external onlyOwner {
        uint256 balance = xToken.balanceOf(address(this));
        require(balance > 0, "MechPet:no xToken");
        xToken.transfer(msg.sender, balance);
    }

    function getPetIdOf(address owner) external view returns (uint256) {
        return petIdOf[owner];
    }

    function readPetMapping(
        uint256[] calldata ups,
        uint256[] calldata downs,
        uint256[] calldata lvs,
        string[] calldata uris
    ) external {
        require(ups.length == downs.length, "MechPet:length not eq");
        require(downs.length == uris.length, "MechPet:length not eq");
        require(uris.length >= 1, "MechPet:uris should >= 1");
        uint256 len = ups.length;
        for (uint256 i = 0; i < len - 1; i++) {
            entrys.push(PetEntry(ups[i], downs[i], lvs[i], uris[i]));
        }
        //last element
        entrys.push(
            PetEntry(ups[len - 1], downs[len - 2], lvs[len - 1], uris[len - 1])
        );
        emit ReadPetMapping(len);
    }

    function _findLv(uint256 exp, uint256 tokenId) internal {
        require(entrys.length != 0, "MechPet: mapping is empty");
        //find cache first
        if (bytes(extrysCached[exp].uri).length != 0) {
            datas[tokenId].lv = extrysCached[exp].lv;
            datas[tokenId].uri = extrysCached[exp].uri;
            emit EntryCacheHit(tokenId, exp);
            return;
        }
        //else binary search
        uint256 left = 0;
        uint256 right = entrys.length - 2;
        while (left <= right) {
            uint mid = left + (right - left) / 2;
            if (entrys[mid].up <= exp) {
                left = mid + 1;
            } else if (entrys[mid].down > exp) {
                right = mid - 1;
            } else if (entrys[mid].down <= exp && exp < entrys[mid].up) {
                left = mid;
                break;
            }
        }
        //cache entry
        datas[tokenId].uri = entrys[left].uri;
        datas[tokenId].lv = entrys[left].lv;

        extrysCached[exp].lv = entrys[left].lv;
        extrysCached[exp].uri = entrys[left].uri;
        emit SearchPetEntry(tokenId, extrysCached[exp].lv);
    }

    //getters
    function getLv(uint256 tokenId) public view returns (uint256) {
        return datas[tokenId].lv;
    }

    function getExp(uint256 tokenId) public view returns (uint256) {
        return datas[tokenId].exp;
    }

    function getPoint(uint256 tokenId) public view returns (uint256) {
        return datas[tokenId].point;
    }

    //only for testnet
    function reset(address owner) public onlyOwner {
        delete petIdOf[owner];
    }
}

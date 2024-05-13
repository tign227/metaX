// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "./interfaces/IMechPet.sol";
contract MechPet is ERC721URIStorage, IMechPet {
    string public constant NAME = "xPet";

    constructor() ERC721("metaX Pet", "xPet") {}

    //tokenId => PetData
    mapping(uint256 => PetData) private datas;
    PetEntry[] private entrys;
    //exp => entry
    mapping(uint256 => PetEntry) private extrysCached;
    //address => tokenId
    mapping(address => uint256) private petIdOf;
    string private initUri =
        "ipfs://QmUgyvKXQvyDUkSnA63dMRRc5j4bbC8WsSy2ftzQpytL2A";
    uint256 private initLv;
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
    }

    event FeedPet(uint256 indexed tokenId, uint256 indexed amount);
    event EntryCacheHit(uint256 indexed tokenId, uint256 indexed exp);
    event SearchPetEntry(uint256 indexed tokenId, uint256 indexed lv);
    event ReadPetMapping(uint256 indexed len);
    event GrowPet(uint256 indexed tokenId, uint256 indexed amount);

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(tokenId >= 1, "MechPet:not mint");
        string memory uri = datas[tokenId].uri;
        bytes memory bytesUri = bytes(uri);
        //when uri is empty, return initUri
        return bytesUri.length == 0 ? initUri : uri;
    }

    function claimFreePet(address to) external {
        require(petIdOf[to] == 0, "MechPet:already claimed");
        _claim(to);
    }

    function _claim(address to) internal {
        _safeMint(to, petId);
        petIdOf[to] = petId;
        datas[petId].uri = initUri;
        datas[petId].lv = initLv;
        petId++;
    }

    function feedPet(uint tokenId, uint256 amount) external {
        require(tokenId >= 1, "MechPet:not mint");
        datas[tokenId].exp += amount;
        emit FeedPet(tokenId, amount);
        _findLv(datas[tokenId].exp, tokenId);
    }

    function growPet(uint tokenId, uint256 amount) external {
        require(tokenId >= 1, "MechPet:not mint");
        datas[tokenId].point += amount;
        emit GrowPet(tokenId, amount);
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
        //init uri
        initUri = uris[0];
        initLv = lvs[0];
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
        uint256 right = entrys.length - 1;
        uint256 i = 0;
        while (left <= right) {
            uint mid = left + (right - left) / 2;
            if (entrys[mid].up <= exp) {
                left = mid + 1;
            } else if (entrys[mid].down > exp) {
                right = mid - 1;
            } else if (entrys[mid].down <= exp && exp < entrys[mid].up) {
                i = mid;
                break;
            }
        }
        //cache entry
        datas[tokenId].uri = entrys[i].uri;
        datas[tokenId].lv = entrys[i].lv;

        extrysCached[exp].lv = entrys[i].lv;
        extrysCached[exp].uri = entrys[i].uri;
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
}

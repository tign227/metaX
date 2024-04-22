// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MechPet is ERC721URIStorage {
    constructor() ERC721("metaX Pet", "xPet") {}
    //tokenId => tokenUrr
    mapping(uint256 => string) tokenUris;
    //tokenId => lv
    mapping(uint256 => uint256) lvs;
    //tokenId => exp
    mapping(uint256 => uint256) exps;
    //tokenId => point
    mapping(uint256 => uint256) points;
    //external expEntry mapping
    LvEntry[] entrys;
    //exp => lv mapping cache
    mapping(uint256 => LvEntry) extrysCached;
    //init uri
    string private initUri;

    struct LvEntry {
        uint256 up;
        uint256 down;
        uint256 lv;
        string uri;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(tokenId > 1, "MechPet:not mint");
        return tokenUris[tokenId];
    }

    function feedPet(uint tokenId, uint256 amount) external {
        require(tokenId > 1, "MechPet:not mint");
        exps[tokenId] += amount;
        _findLv(exps[tokenId], tokenId);
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
        for (uint256 i = 0; i < len - 1; i++) {
            entrys[i] = LvEntry(ups[i + 1], downs[i], i, uris[i]);
        }
        //last element
        entrys[len] = LvEntry(ups[len - 1], downs[len - 2], len, uris[len - 1]);
    }

    function _findLv(
        uint256 exp,
        uint256 tokenId
    ) internal returns (uint256 lv) {
        require(entrys.length != 0, "MechPet: mapping is empty");
        //find cache first
        if (bytes(extrysCached[exp].uri).length != 0) {
            lvs[tokenId] = extrysCached[exp].lv;
            tokenUris[tokenId] = extrysCached[exp].uri;
            return lvs[tokenId];
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
        lvs[tokenId] = entrys[i].lv;
        tokenUris[tokenId] = entrys[i].uri;
        extrysCached[exp] = entrys[i];
        return lvs[tokenId];
    }
}

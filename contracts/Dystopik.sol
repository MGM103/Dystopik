//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";

contract Dystopik is ERC721Enumerable {
    //Token ID
    using Counters for Counters.Counter;
    Counters.Counter public _characterID;

    //Contains the avatar images for the different characters that can be created
    string[] imageURIs;

    //Connecting token ID to respective characteristics
    mapping(uint256 => uint256) public xp;
    mapping(uint256 => uint256) public level;
    mapping(uint256 => uint256) public architype;
    mapping(uint256 => string) public imageURI;

    event characterCreated(address indexed owner, uint256 characterID, uint256 architype);
    event leveledUp(address indexed owner, uint256 characterID, uint256 level);

    constructor(string[] memory _imageURIs) ERC721("Dystopik", "DYST"){
        //Setting the avatars for the character types
        for(uint256 i = 0; i < _imageURIs.length; i++){
            imageURIs.push(_imageURIs[i]);
        }

        //The first character to be minted should have an ID of 1
        _characterID.increment();
    }

    function createCharacter(uint256 _architype) external {
        require(_architype >= 1 && _architype < 4);
        
        uint256 nextID = _characterID.current();
        architype[nextID] = _architype;
        level[nextID] = 1;
        imageURI[nextID] = imageURIs[_architype - 1];

        _safeMint(msg.sender, nextID);

        emit characterCreated(msg.sender, nextID, _architype);

        _characterID.increment();
    }

    function getCharacter(uint256 _tokenID) external view returns(uint256, uint256, uint256, string memory){
        uint256 _xp = xp[_tokenID];
        uint256 _level = level[_tokenID];
        uint256 _architype = architype[_tokenID];
        string memory _imageURI = imageURI[_tokenID];

        return (_xp, _level, _architype, _imageURI);
    }

    function levelUp(uint256 _tokenID) external {
        require(_isApprovedOrOwner(msg.sender, _tokenID));
        require(canLevelUp(_tokenID));

        uint256 currentLvl = level[_tokenID];
        uint256 currentXp = xp[_tokenID];

        level[_tokenID] = currentLvl + 1;
        xp[_tokenID] = currentXp - nextLevelXp(currentLvl);

        emit leveledUp(msg.sender, _tokenID, currentLvl+1);
    }

    function canLevelUp(uint256 _tokenID) view internal returns(bool) {
        uint256 currentLvl = level[_tokenID];
        uint256 currentXp = xp[_tokenID];

        if(currentXp >= nextLevelXp(currentLvl)){
            return true;
        }else {
            return false;
        }
    }

    function nextLevelXp(uint256 _level) pure internal returns(uint256){
        uint256 baseXp = 1000;
        uint256 exponent = 2;

        return baseXp * (_level ** exponent);
    }

    function architypeToString(uint256 _architype) public pure returns(string memory){
        if(_architype == 1){
            return "Chimera";
        }else if(_architype == 2){
            return "Android";
        }else{
            return "AI";
        }
    }
}

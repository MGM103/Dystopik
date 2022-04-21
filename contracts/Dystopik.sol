/** 
 *  @fileOverview This file is the base ERC721 contract for the characters in the Dystopik game.
 *  @author     Marcus Marinelli
 *  @version    0.1.0
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";

contract Dystopik is ERC721Enumerable, AccessControl {
    //Token ID
    using Counters for Counters.Counter;
    Counters.Counter public _characterID;

    //Contains the avatar images for the different characters that can be created
    string[] imageURIs;

    //Defining role(s)
    bytes32 public constant XP_GIVER = keccak256("XP_GIVER");

    //Connecting token ID to respective characteristics
    mapping(uint256 => uint256) public xp;
    mapping(uint256 => uint256) public level;
    mapping(uint256 => uint256) public architype;
    mapping(uint256 => string) public imageURI;

    event characterCreated(address indexed owner, uint256 characterID, uint256 architype);
    event leveledUp(address indexed owner, uint256 characterID, uint256 level);
    event gainedXp(address owner, uint256 charcterID, uint256 xpGained);

    /**
     *  Initialises the ERC721, stores images of all the avatars.
     *  @param _imageURIs {string[]} - An array of the imageURIs for all the avatar architypes.
     */
    constructor(string[] memory _imageURIs) ERC721("Dystopik", "DYST"){
        //Set permissions
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(XP_GIVER, msg.sender);
        
        //Setting the avatars for the character types
        for(uint256 i = 0; i < _imageURIs.length; i++){
            imageURIs.push(_imageURIs[i]);
        }

        //The first character to be minted should have an ID of 1
        _characterID.increment();
    }

    /**
     *  Mints the ERC721 token, the user's character
     *  @notice requires the architype variable to be between 1 & 3, as they are the only valid architype vals
     *  @param _architype {uint256} - The type of the avatar.
     */
    function createCharacter(uint256 _architype) external {
        require(_architype >= 1 && _architype < 4, "Architype does not exist");
        
        uint256 nextID = _characterID.current();
        architype[nextID] = _architype;
        level[nextID] = 1;
        imageURI[nextID] = imageURIs[_architype - 1];

        _safeMint(msg.sender, nextID);

        emit characterCreated(msg.sender, nextID, _architype);

        _characterID.increment();
    }

    /**
     *  This function retrieves all base level information regarding a user's character.
     *  @param _tokenID {uint256} - The id of the character whoose info we're looking up.
     *  @return _xp {uint256} - The current xp a character has.
     *  @return _level {uint256} - The currrent level of the character.
     *  @return _architype {uint256} - The type or class of the character.
     *  @return _imageURI {string} - The image of the character.
     */
    function getCharacter(uint256 _tokenID) external view returns(uint256, uint256, uint256, string memory){
        uint256 _xp = xp[_tokenID];
        uint256 _level = level[_tokenID];
        uint256 _architype = architype[_tokenID];
        string memory _imageURI = imageURI[_tokenID];

        return (_xp, _level, _architype, _imageURI);
    }

    /**
     *  Function to level up the character.
     *  @notice requires the msg.sender to be the owner or approved
     *  @notice requires the character to have the requisite xp to level up
     *  @param _tokenID {uint256} - The token ID of the character that is being levelled up.
     */
    function levelUp(uint256 _tokenID) external {
        require(_isApprovedOrOwner(msg.sender, _tokenID), "You do not have approval to perform this action");
        require(canLevelUp(_tokenID), "Insufficent xp");

        uint256 currentLvl = level[_tokenID];
        uint256 currentXp = xp[_tokenID];

        level[_tokenID] = currentLvl + 1;
        xp[_tokenID] = currentXp - nextLevelXp(currentLvl);

        emit leveledUp(msg.sender, _tokenID, currentLvl+1);
    }

    /**
     *  This function determines whether a charcter has sufficient xp to level up.
     *  @param _tokenID {uint256} - The token ID of the character whose xp is being checked.
     *  @return canLevel {bool} - returns whether the player can level up.
     */
    function canLevelUp(uint256 _tokenID) view internal returns(bool) {
        uint256 currentLvl = level[_tokenID];
        uint256 currentXp = xp[_tokenID];
        bool canLevel;

        if(currentXp >= nextLevelXp(currentLvl)){
            canLevel = true;
            return canLevel;
        }else {
            canLevel = false;
            return canLevel;
        }
    }

    /**
     * This function determines the amount of xp required to reach the next level
     * @param _level {uint256} - The level that is being checked for the xp requirement.
     * @return xpNextLevel {uint256} - The xp required to reach _level.
     */
    function nextLevelXp(uint256 _level) pure internal returns(uint256){
        uint256 baseXp = 1000;
        uint256 exponent = 2;
        uint256 xpNextLevel = baseXp * (_level ** exponent);

        return xpNextLevel;
    }

    /**
     *  This function converts the numerical representation of architype to a string.
     *  @param _architype {uint256} - This is the type or class of a character.
     *  @return {string} - The string of the type or class of the character.
     */
    function architypeToString(uint256 _architype) public pure returns(string memory){
        if(_architype == 1){
            return "Chimera";
        }else if(_architype == 2){
            return "Android";
        }else{
            return "AI";
        }
    }

    /**
     *  This function is used to award charcters xp after a quest
     *  @notice requires the msg.sender to be the owner or approved
     *  @param _tokenID {uint256} - The character who will receive xp
     *  @param _amountXp {uint256} - The amount of xp the character will be receiving
     */
    function gainXp(uint256 _tokenID, uint256 _amountXp) external {
        require(_isApprovedOrOwner(msg.sender, _tokenID), "You do not have approval to perform this action");
        
        xp[_tokenID] += _amountXp;
        emit gainedXp(msg.sender, _tokenID, _amountXp);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

/** 
 *  @fileOverview This file is the base ERC721 contract for the characters in the Dystopik game.
 *  @author     Marcus Marinelli
 *  @version    0.1.0
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//libraries
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";
import "./libraries/Structs.sol";

//Interfaces
import "./interfaces/IAttributes.sol";

contract Dystopik is ERC721Enumerable, AccessControl {
    //Interfaces
    IAttributes Attributes;
    
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
     *  This function is used to award charcters xp after a quest
     *  @notice requires the msg.sender to be the owner or approved
     *  @param _tokenID {uint256} - The character who will receive xp
     *  @param _amountXp {uint256} - The amount of xp the character will be receiving
     */
    function gainXp(uint256 _tokenID, uint256 _amountXp) external onlyRole(XP_GIVER) {
        require(_isApprovedOrOwner(msg.sender, _tokenID), "You do not have approval to perform this action");//Is this necessary with RBAC?
        
        xp[_tokenID] += _amountXp;
        emit gainedXp(msg.sender, _tokenID, _amountXp);
    }

    function setAttributesInterface(address _addressInterface) external {
        Attributes = IAttributes(_addressInterface);
    }

    function getAttributes(uint256 _tokenID) public view returns(uint256,uint256,uint256,uint256,uint256,uint256, uint256) {
        return Attributes.idToAttributes(_tokenID);
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
    function nextLevelXp(uint256 _level) pure public returns(uint256) {
        uint256 baseXp = 100;
        uint256 exponent = 2;
        uint256 xpNextLevel = baseXp * (_level ** exponent);

        return xpNextLevel;
    }

    /**
     *  This function converts the numerical representation of architype to a string.
     *  @param _architype {uint256} - This is the type or class of a character.
     *  @return {string} - The string of the type or class of the character.
     */
    function architypeToString(uint256 _architype) public pure returns(string memory) {
        if(_architype == 1){
            return "Chimera";
        }else if(_architype == 2){
            return "Android";
        }else{
            return "AI";
        }
    }

    function tokenURIBase(uint256 _tokenID) internal view returns(string memory) {
        string memory currentXp = Strings.toString(xp[_tokenID]);
        string memory nextLvlXp = Strings.toString(nextLevelXp(level[_tokenID]));
        string memory currentLevel = Strings.toString(level[_tokenID]);
        string memory strArchitype = architypeToString(architype[_tokenID]);

        string memory baseURI = string(abi.encodePacked('{ "trait_type": "Level", "value": "',
            currentLevel,'"}, { "trait_type": "Experience", "value": ', currentXp,', "max_value":', nextLvlXp,'}, { "trait_type": "Architype", "value": "',
            strArchitype,'"},'
        ));

        return baseURI;
    }

    function attributesToString(uint256 _tokenID) internal view returns(dl._StrCharAttributes memory) {
        (uint256 strength, uint256 speed, uint256 fortitude, uint256 technical, uint256 instinct, uint256 dexterity, uint256 luck) = getAttributes(_tokenID);

        dl._StrCharAttributes memory strAttributes = dl._StrCharAttributes(
            Strings.toString(strength),
            Strings.toString(speed),
            Strings.toString(fortitude),
            Strings.toString(technical),
            Strings.toString(instinct),
            Strings.toString(dexterity),
            Strings.toString(luck)
        );

        return strAttributes;
    }

    /**
     * This function exists because of stack too deep. I needed to seperate the retrieval and stringifying of the attribute values.
     */
    function tokenURIAttributes(uint256 _tokenID) internal view returns(string memory) {
        dl._StrCharAttributes memory _strAttributes = attributesToString(_tokenID);

        string memory attributesURI = string(abi.encodePacked(' { "trait_type": "Strength", "value": "', _strAttributes.strength,
            '"}, { "trait_type": "Speed", "value": "', _strAttributes.speed,'"}, { "trait_type": "Fortitude", "value": "', _strAttributes.fortitude,'"}, { "trait_type": "Technical", "value": "',
            _strAttributes.technical,'"}, { "trait_type": "Instinct", "value": "', _strAttributes.instinct,'"}, { "trait_type": "Dexterity", "value": "', _strAttributes.dexterity,'"}, { "trait_type": "Luck", "value": "',
            _strAttributes.luck,'"}'
        ));

        return attributesURI;
    }

    function tokenURI(uint256 _tokenId) public view override returns(string memory) {
        string memory baseURI = tokenURIBase(_tokenId);
        string memory attributesURI = tokenURIAttributes(_tokenId);

        string memory imgURI = imageURI[_tokenId];

        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "Dystopik',
                ' -- NFT #: ',
                Strings.toString(_tokenId),
                '", "description": "Avatars for a turn based blockchain RPG", "image": "',
                imgURI,
                '", "attributes": [',  baseURI, attributesURI, ']}'   
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable, AccessControl) returns(bool) {
        return super.supportsInterface(interfaceId);
    }
}

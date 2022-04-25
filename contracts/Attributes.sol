/** 
 *  @fileOverview This file is dedicated to the attributes of the characters
 *  @author     Marcus Marinelli
 *  @version    0.1.0
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/Dystopik_Interface.sol";

contract Attributes {
    //interface to the base contract
    Dystopik_Interface immutable dyst; 
    
    //The amount of attributes characters at level one can spend
    uint256 constant initAttributePoints = 25;

    struct CharAttributes {
        uint256 strength;
        uint256 speed;
        uint256 fortitude;
        uint256 technical;
        uint256 instinct;
        uint256 dexterity;
        uint256 luck;
    }

    mapping(uint256 => CharAttributes) public idToAttributes;
    mapping(uint256 => uint256) public idToAttributePointsSpent;
    mapping(uint256 => bool) public initAttributesSet;

    event initialisedAttributes(address indexed setter, uint256 tokenID, uint256 strength, uint256 speed, uint256 fortitude, uint256 technical, uint256 instinct, uint256 dexterity, uint256 luck);
    event attributesUpgraded(address indexed updater, uint256 tokenID, uint256 strength, uint256 speed, uint256 fortitude, uint256 technical, uint256 instinct, uint256 dexterity, uint256 luck);
    
    /**
     *  @param _interfaceAddr {address} - The address of the base contract.
     */
    constructor(address _interfaceAddr) {
        dyst = Dystopik_Interface(_interfaceAddr);
    }

    /**
     *  @notice Used to verify that the msg.sender has permission to interact with the character.
     *  @param _tokenID {uint256} - The id of the character NFT that is being interacted with.
     */
    function _isApprovedOrOwner(uint256 _tokenID) internal view returns (bool) {
        return dyst.getApproved(_tokenID) == msg.sender || dyst.ownerOf(_tokenID) == msg.sender;
    }

    /**
     *  @notice This function sets the attribute points to the respective attributes the user chooses when the character is created
     *  @param _tokenID {uint256} - The id of the NFT whose init attributes are being set.
     *  @param _strength {uint256} - The number of attribute points being assigned to strength.
     *  @param _speed {uint256} - The number of attribute points being assigned to speed.
     *  @param _fortitude {uint256} - The number of attribute points being assigned to fortitude.
     *  @param _technical {uint256} - The number of attribute points being assigned to technical.
     *  @param _dexterity {uint256} - The number of attribute points being assigned to dexterity.
     *  @param _luck {uint256} - The number of attribute points being assigned to luck.
     */
    function setInitAttributes(uint256 _tokenID, uint256 _strength, uint256 _speed, uint256 _fortitude, uint256 _technical, uint256 _instinct, uint256 _dexterity, uint256 _luck) external {
        require(_isApprovedOrOwner(_tokenID), "You do not have permission to set attributes");
        require(!initAttributesSet[_tokenID], "Initial attributes have already been set");
        require(calcInitAttributes(_strength, _speed, _fortitude, _technical, _instinct, _dexterity, _luck), "All initial attribute points must be used");

        initAttributesSet[_tokenID] = true;
        idToAttributes[_tokenID] = CharAttributes(
            _strength,
            _speed,
            _fortitude,
            _technical,
            _instinct,
            _dexterity,
            _luck
        );

        emit initialisedAttributes(msg.sender, _tokenID, _strength, _speed, _fortitude, _technical, _instinct, _dexterity, _luck);
    }

    /**
     *  This function calculates the amount of attributes being spent when initially assigning attributes is equal to the amount to spend
     *  @param _strength {uint256} - The number of attribute points being assigned to strength.
     *  @param _speed {uint256} - The number of attribute points being assigned to speed.
     *  @param _fortitude {uint256} - The number of attribute points being assigned to fortitude.
     *  @param _technical {uint256} - The number of attribute points being assigned to technical.
     *  @param _dexterity {uint256} - The number of attribute points being assigned to dexterity.
     *  @param _luck {uint256} - The number of attribute points being assigned to luck.
     */
    function calcInitAttributes(uint256 _strength, uint256 _speed, uint256 _fortitude, uint256 _technical, uint256 _instinct, uint256 _dexterity, uint256 _luck) internal pure returns(bool){
        uint256 initSpendTotal = _strength + _speed + _fortitude + _technical + _instinct + _dexterity + _luck;

        if(initSpendTotal == initAttributePoints){
            return true;
        }else{
            return false;
        }
    }

    /**
     *  This function is used to register a stat being upgraded after all init attribute points have been spent
     *  @param _tokenID {uint256} - the character who is spending attribute points to boost an attribute
     */
    function updateAttributes(uint256 _tokenID) internal {
        require(_isApprovedOrOwner(_tokenID), "You do not have permission to upgrade attributes");
        require(initAttributesSet[_tokenID], "Initial attributes have not been set");

        uint256 pointsSpent = idToAttributePointsSpent[_tokenID];

        require(pointsSpent < calcAvailablePts(_tokenID), "Insufficent attribute points");

        idToAttributePointsSpent[_tokenID] += 1;
    }

    /**
     *  This function is used to determine how many attribute points a character can spend at their current level.
     *  Only used once initial attributes have been spent
     *  @param _tokenID {uint256} - The character whose attribute points is being assessed.
     */
    function calcAvailablePts(uint256 _tokenID) public view returns(uint256){
        uint256 currentLvl = dyst.level(_tokenID);
        uint availablePts = (currentLvl - 1) * 5; //may need to change
        return availablePts;
    }

    /**
     *  This function increasese the strength of a character.
     *  @param _tokenID {uint256} - The charachter whose strength is being upgraded.
     */
    function increaseStr(uint256 _tokenID) external {
        updateAttributes(_tokenID);
        CharAttributes storage attributeLvls = idToAttributes[_tokenID];
        attributeLvls.strength += 1;

        emit attributesUpgraded(msg.sender, _tokenID, attributeLvls.strength, attributeLvls.speed, attributeLvls.fortitude, attributeLvls.technical, attributeLvls.instinct, attributeLvls.dexterity, attributeLvls.luck);
    }

    /**
     *  This function increasese the speed of a character.
     *  @param _tokenID {uint256} - The charachter whose speed is being upgraded.
     */
    function increaseSpd(uint256 _tokenID) external {
        updateAttributes(_tokenID);
        CharAttributes storage attributeLvls = idToAttributes[_tokenID];
        attributeLvls.speed += 1;

        emit attributesUpgraded(msg.sender, _tokenID, attributeLvls.strength, attributeLvls.speed, attributeLvls.fortitude, attributeLvls.technical, attributeLvls.instinct, attributeLvls.dexterity, attributeLvls.luck);
    }

    /**
     *  This function increasese the fortitude of a character.
     *  @param _tokenID {uint256} - The charachter whose fortitude is being upgraded.
     */
    function increaseFort(uint256 _tokenID) external {
        updateAttributes(_tokenID);
        CharAttributes storage attributeLvls = idToAttributes[_tokenID];
        attributeLvls.fortitude += 1;

        emit attributesUpgraded(msg.sender, _tokenID, attributeLvls.strength, attributeLvls.speed, attributeLvls.fortitude, attributeLvls.technical, attributeLvls.instinct, attributeLvls.dexterity, attributeLvls.luck);
    }

    /**
     *  This function increasese the technical of a character.
     *  @param _tokenID {uint256} - The charachter whose technical is being upgraded.
     */
    function increaseTech(uint256 _tokenID) external {
        updateAttributes(_tokenID);
        CharAttributes storage attributeLvls = idToAttributes[_tokenID];
        attributeLvls.technical += 1;

        emit attributesUpgraded(msg.sender, _tokenID, attributeLvls.strength, attributeLvls.speed, attributeLvls.fortitude, attributeLvls.technical, attributeLvls.instinct, attributeLvls.dexterity, attributeLvls.luck);
    }

    /**
     *  This function increasese the technical of a character.
     *  @param _tokenID {uint256} - The charachter whose technical is being upgraded.
     */
    function increaseInstinct(uint256 _tokenID) external {
        updateAttributes(_tokenID);
        CharAttributes storage attributeLvls = idToAttributes[_tokenID];
        attributeLvls.instinct += 1;

        emit attributesUpgraded(msg.sender, _tokenID, attributeLvls.strength, attributeLvls.speed, attributeLvls.fortitude, attributeLvls.technical, attributeLvls.instinct, attributeLvls.dexterity, attributeLvls.luck);
    }

    /**
     *  This function increasese the reflexes of a character.
     *  @param _tokenID {uint256} - The charachter whose reflexes are being upgraded.
     */
    function increaseDex(uint256 _tokenID) external {
        updateAttributes(_tokenID);
        CharAttributes storage attributeLvls = idToAttributes[_tokenID];
        attributeLvls.dexterity += 1;

        emit attributesUpgraded(msg.sender, _tokenID, attributeLvls.strength, attributeLvls.speed, attributeLvls.fortitude, attributeLvls.technical, attributeLvls.instinct, attributeLvls.dexterity, attributeLvls.luck);
    }

    /**
     *  This function increasese the luck of a character.
     *  @param _tokenID {uint256} - The charachter whose luck is being upgraded.
     */
    function increaseLuck(uint256 _tokenID) external {
        updateAttributes(_tokenID);
        CharAttributes storage attributeLvls = idToAttributes[_tokenID];
        attributeLvls.luck += 1;

        emit attributesUpgraded(msg.sender, _tokenID, attributeLvls.strength, attributeLvls.speed, attributeLvls.fortitude, attributeLvls.technical, attributeLvls.instinct, attributeLvls.dexterity, attributeLvls.luck);
    }
}
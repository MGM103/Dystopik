//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/Dystopik_Interface.sol";

contract Attributes {
    Dystopik_Interface immutable dyst;
    uint256 constant initAttributePoints = 25;

    struct CharAttributes {
        uint256 strength;
        uint256 speed;
        uint256 fortitude;
        uint256 technical;
        uint256 reflexes;
        uint256 luck;
    }

    mapping(uint256 => CharAttributes) public idToAttributes;
    mapping(uint256 => uint256) public attributePointsSpent;
    mapping(uint256 => bool) public initAttributesSet;

    event initialisedAttributes(address indexed setter, uint256 tokenID, uint256 strength, uint256 speed, uint256 fortitude, uint256 technical, uint256 reflexes, uint256 luck);
    event attributesUpdated(address indexed updater, uint256 tokenID, uint256 strength, uint256 speed, uint256 fortitude, uint256 technical, uint256 reflexes, uint256 luck);
    
    constructor(address _interfaceAdddr) {
        dyst = Dystopik_Interface(_interfaceAdddr);
    }

    function _isApprovedOrOwner(uint256 _tokenID) internal view returns (bool) {
        return dyst.getApproved(_tokenID) == msg.sender || dyst.ownerOf(_tokenID) == msg.sender;
    }

    function setInitAttributes(uint256 _tokenID, uint256 _strength, uint256 _speed, uint256 _fortitude, uint256 _technical, uint256 _reflexes, uint256 _luck) external {
        require(_isApprovedOrOwner(_tokenID), "You do not have permission to set attributes");
        require(!initAttributesSet[_tokenID], "Initial attributes have already been set");
        require(calcInitAttributes(_strength, _speed, _fortitude, _technical, _reflexes, _luck), "All initial attribute points must be used");

        initAttributesSet[_tokenID] = true;
        idToAttributes[_tokenID] = CharAttributes(
            _strength,
            _speed,
            _fortitude,
            _technical,
            _reflexes,
            _luck
        );

        emit initialisedAttributes(msg.sender, _tokenID, _strength, _speed, _fortitude, _technical, _reflexes, _luck);
    }

    function calcInitAttributes(uint256 _strength, uint256 _speed, uint256 _fortitude, uint256 _technical, uint256 _reflexes, uint256 _luck) internal pure returns(bool){
        uint256 initSpendTotal = _strength + _speed + _fortitude + _technical + _reflexes + _luck;

        if(initSpendTotal == initAttributePoints){
            return true;
        }else{
            return false;
        }
    }

    function updateAttributes(uint256 _tokenID) internal {
        require(_isApprovedOrOwner(_tokenID), "You do not have permission to set attributes");
        require(initAttributesSet[_tokenID], "Initial attributes have not been set");

        uint256 pointsSpent = attributePointsSpent[_tokenID];

        require(pointsSpent < calcAvailablePts(_tokenID));

        attributePointsSpent[_tokenID] += 1;
    }

    function calcAvailablePts(uint256 _tokenID) public view returns(uint256){
        uint256 currentLvl = dyst.level(_tokenID);
        uint availablePts = (currentLvl - 1) * 5;
        return availablePts;
    }

    function increaseStr(uint256 _tokenID) external {
        updateAttributes(_tokenID);
        CharAttributes storage attributeLvls = idToAttributes[_tokenID];
        attributeLvls.strength += 1;

        emit attributesUpdated(msg.sender, _tokenID, attributeLvls.strength, attributeLvls.speed, attributeLvls.fortitude, attributeLvls.technical, attributeLvls.reflexes, attributeLvls.luck);
    }

    function increaseSpd(uint256 _tokenID) external {
        updateAttributes(_tokenID);
        CharAttributes storage attributeLvls = idToAttributes[_tokenID];
        attributeLvls.speed += 1;

        emit attributesUpdated(msg.sender, _tokenID, attributeLvls.strength, attributeLvls.speed, attributeLvls.fortitude, attributeLvls.technical, attributeLvls.reflexes, attributeLvls.luck);
    }

    function increaseFort(uint256 _tokenID) external {
        updateAttributes(_tokenID);
        CharAttributes storage attributeLvls = idToAttributes[_tokenID];
        attributeLvls.fortitude += 1;

        emit attributesUpdated(msg.sender, _tokenID, attributeLvls.strength, attributeLvls.speed, attributeLvls.fortitude, attributeLvls.technical, attributeLvls.reflexes, attributeLvls.luck);
    }

    function increaseTech(uint256 _tokenID) external {
        updateAttributes(_tokenID);
        CharAttributes storage attributeLvls = idToAttributes[_tokenID];
        attributeLvls.technical += 1;

        emit attributesUpdated(msg.sender, _tokenID, attributeLvls.strength, attributeLvls.speed, attributeLvls.fortitude, attributeLvls.technical, attributeLvls.reflexes, attributeLvls.luck);
    }

    function increaseRflx(uint256 _tokenID) external {
        updateAttributes(_tokenID);
        CharAttributes storage attributeLvls = idToAttributes[_tokenID];
        attributeLvls.reflexes += 1;

        emit attributesUpdated(msg.sender, _tokenID, attributeLvls.strength, attributeLvls.speed, attributeLvls.fortitude, attributeLvls.technical, attributeLvls.reflexes, attributeLvls.luck);
    }

    function increaseLuck(uint256 _tokenID) external {
        updateAttributes(_tokenID);
        CharAttributes storage attributeLvls = idToAttributes[_tokenID];
        attributeLvls.luck += 1;

        emit attributesUpdated(msg.sender, _tokenID, attributeLvls.strength, attributeLvls.speed, attributeLvls.fortitude, attributeLvls.technical, attributeLvls.reflexes, attributeLvls.luck);
    }
}
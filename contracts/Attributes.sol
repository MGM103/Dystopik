//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/Dystopik_Interface.sol";

contract Attributes {
    Dystopik_Interface immutable dyst;

    struct CharAttributes {
        uint256 strength;
        uint256 speed;
        uint256 forititude;
        uint256 technical;
        uint256 reflexes;
        uint256 luck;
    }

    mapping(uint256 => CharAttributes) public idToAttributes;
    mapping(uint256 => uint256) public attributePointsSpent;
    mapping(uint256 => bool) public initAttributesSet;

    event initAttributes(address indexed setter, uint256 tokenID, uint256 strength, uint256 speed, uint256 fortitude, uint256 technical, uint256 reflexes, uint256 luck);
    event attributesUpdated(address indexed updater, uint256 tokenID, uint256 strength, uint256 speed, uint256 fortitude, uint256 technical, uint256 reflexes, uint256 luck);
    
    constructor(address _interfaceAdddr) {
        dyst = Dystopik_Interface(_interfaceAdddr);
    }

    function _isApprovedOrOwner(uint _summoner) internal view returns (bool) {
        return dyst.getApproved(_summoner) == msg.sender || dyst.ownerOf(_summoner) == msg.sender;
    }
}
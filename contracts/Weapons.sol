/** 
 *  @fileOverview This file is dedicated to the attributes of the characters
 *  @author     Marcus Marinelli
 *  @version    0.1.0
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";
import "./libraries/Structs.sol";

//Interfaces
import "./interfaces/IWeaponManifest.sol";

contract Weapons is ERC721, ERC721Enumerable, ERC721Burnable, AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    //Interfaces
    IWeaponManifest manifest;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => dl._Weapon) public idToStats;

    event weaponMinted(address indexed minter, uint256 tokenID, dl._Weapon newWeapon);

    constructor() ERC721("Dystopik Weapons", "WPNS") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _tokenIdCounter.increment(); //start at 1
    }

    //No permission atm, will be added in future to work with openzeppelin defender
    function createWeapon(uint256 _wpnVariant) external {
        require(_wpnVariant > 0 && _wpnVariant <= manifest.totalVariants(), "Invalid Weapon Variant");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        dl._Weapon memory wpnType = manifest.idToWpn(_wpnVariant);
        idToStats[tokenId] = wpnType;

        _safeMint(msg.sender, tokenId);
        
        emit weaponMinted(msg.sender, tokenId, wpnType);
    }

    function tokenURI(uint256 _tokenId) public view override returns(string memory){
        dl._Weapon memory wpnData = idToStats[_tokenId];
        string memory supplyStr = tokenURILimitedSupply(wpnData);
        string memory wpnType = manifest.wpnTypeToStr(wpnData.damageType);

        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "', wpnData.name,
                '", "description": "', wpnData.description, '", "image": "',
                wpnData.imageURI,
                '", "attributes": [{ "trait_type": "Damage Type", "value": "', wpnType,
                '"}, ', supplyStr, ', {"trait_type": "Cost", "value":"', Strings.toString(wpnData.cost), '"}, {"trait_type": "Weight", "value":"', 
                Strings.toString(wpnData.weight), '"}, {"trait_type": "Min Damage", "value":"', Strings.toString(wpnData.damageMin), 
                '"}, {"trait_type": "Max Damage", "value":"', Strings.toString(wpnData.damageMax), '"}, {"trait_type": "Crit Chance", "value":"', 
                Strings.toString(wpnData.critChance), '"}]}'   
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function tokenURILimitedSupply(dl._Weapon memory _wpn) internal pure returns(string memory){
        if(_wpn.limitedSupply){
            string memory limitedSupplyStr = string(abi.encodePacked(
                '{ "trait_type": "Limited Supply", "value": "true"}, {"trait_type": "Max Limit", "value":', _wpn.limit, '}'
            ));
            return limitedSupplyStr;
        }else {
            string memory limitedSupplyStr = string(abi.encodePacked(
                '{ "trait_type": "Limited Supply", "value": "false"}'
            ));
            return limitedSupplyStr;
        }
    }

    function setManifestInterface(address _interfaceAddr) external {
        manifest = IWeaponManifest(_interfaceAddr);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../libraries/Structs.sol";

interface IWeaponManifest {
    function idToWpn(uint256) external view returns (dl._Weapon memory);
    function wpnTypeToStr(uint256) external pure returns (string memory);
    function totalVariants() external pure returns(uint256);
}
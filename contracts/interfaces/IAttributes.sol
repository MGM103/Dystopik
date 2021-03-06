//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IAttributes {
    function initAttributesSet(uint) external view returns (bool);
    function idToAttributes(uint) external view returns (uint256,uint256,uint256,uint256,uint256,uint256, uint256);
}
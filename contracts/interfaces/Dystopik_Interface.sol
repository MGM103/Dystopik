//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface Dystopik_Interface {
    function level(uint) external view returns (uint256);
    function getApproved(uint) external view returns (address);
    function ownerOf(uint) external view returns (address);
}
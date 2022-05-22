//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IDystopik {
    function level(uint) external view returns (uint256);
    function getApproved(uint) external view returns (address);
    function ownerOf(uint) external view returns (address);
}
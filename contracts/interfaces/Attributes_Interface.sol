//SPDX-License-Identifier: Unlicense

interface Attributes_Interface {
    function initAttributesSet(uint) external view returns (bool);
    function idToAttributes(uint) external view returns (uint256,uint256,uint256,uint256,uint256,uint256);
}
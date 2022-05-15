/** 
 *  @fileOverview This file contains the structs or datatypes that are shared amongst contracts
 *  @author     Marcus Marinelli
 *  @version    0.1.0
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library dl {
    struct _CharAttributes {
        uint256 strength;
        uint256 speed;
        uint256 fortitude;
        uint256 technical;
        uint256 instinct;
        uint256 dexterity;
        uint256 luck;
    }

    struct _StrCharAttributes {
        string strength;
        string speed;
        string fortitude;
        string technical;
        string instinct;
        string dexterity;
        string luck;
    }
}
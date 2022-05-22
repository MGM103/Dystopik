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

    struct _Weapon {
        uint256 id;
        uint256 cost;
        uint256 proficiency;
        uint256 weight;
        uint256 damage_type;
        uint256 damage;
        uint256 crit_chance;
        uint256 limit;
        string name;
        string description;
        string imageURI;
        bool limit_type;
    }
}
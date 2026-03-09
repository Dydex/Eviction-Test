// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Access} from "../src/Access.sol";

contract AccessTest is Test {


    function setUp() {
            address[] memory owners = new address[](3);
            owners[0] = address(0x1);
            owners[1] = address(0x2);
            owners[2] = address(0x3);
    
            Access access = new Access(owners, 2);  

    }   
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";

contract UniswapV2FactoryTest is Test {
    UniswapV2Factory public uniswapv2factory;

    Account public owner = makeAccount("owner");
    Account public user = makeAccount("user");

    function setUp() public {
        uniswapv2factory = new UniswapV2Factory(owner.addr);
    }
}

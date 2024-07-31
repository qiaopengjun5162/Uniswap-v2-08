// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {UniswapV2Router02} from "../src/UniswapV2Router02.sol";

contract UniswapV2Router02Test is Test {
    UniswapV2Router02 public uniswapv2router02;

    Account public owner = makeAccount("owner");
    Account public user = makeAccount("user");

    function setUp() public {
        // uniswapv2router02 = new UniswapV2Router02(owner.addr);
    }
}

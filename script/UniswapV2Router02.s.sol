// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {UniswapV2Router02} from "../src/UniswapV2Router02.sol";

contract UniswapV2Router02Script is Script {
    UniswapV2Router02 public uniswapv2router02;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with the account:", deployerAddress);
        vm.startBroadcast(deployerPrivateKey);

        // uniswapv2router02 = new UniswapV2Router02();

        vm.stopBroadcast();
    }
}

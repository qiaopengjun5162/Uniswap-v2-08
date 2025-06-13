// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {UniswapV2Router02} from "../src/UniswapV2Router02.sol";

contract UniswapV2Router02Script is Script {
    UniswapV2Router02 public uniswapv2router02;

    function setUp() public {}

    function run() public {
        address uniswapv2factory = vm.envAddress("UNISWAPV2FACTORY");
        address weth9 = vm.envAddress("WETH9");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with the account:", deployerAddress);
        vm.startBroadcast(deployerPrivateKey);

        uniswapv2router02 = new UniswapV2Router02(uniswapv2factory, weth9);
        console.log("UniswapV2Router02 deployed to: ",address(uniswapv2router02));
        console.log(address(uniswapv2router02));

        string memory path = "./deployments/UniswapV2Router02.json";
        string memory data = string(
            abi.encodePacked(
                '{"deployerAddress": "',
                vm.toString(address(deployerAddress)),
                '", ',
                '"UniswapV2Router02": "',
                vm.toString(address(uniswapv2router02)),
                '", ',
                '"UniswapV2Factory": "',
                vm.toString(address(uniswapv2factory)),
                '", ',
                '"WETH9": "',
                vm.toString(address(weth9)),
                '"}'
            )
        );
        vm.writeJson(data, path);

        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console2} from "forge-std/Script.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";

contract UniswapV2FactoryScript is Script {
    UniswapV2Factory public uniswapv2factory;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console2.log("Deploying contracts with the account:", deployerAddress);
        vm.startBroadcast(deployerPrivateKey);

        uniswapv2factory = new UniswapV2Factory(deployerAddress);
        console2.log("UniswapV2Factory deployed to:");
        console2.log(address(uniswapv2factory));

        string memory path = "deployed_addresses.json";
        string memory data = string(
            abi.encodePacked(
                '{"deployerAddress": "',
                vm.toString(address(deployerAddress)),
                '", ',
                '"uniswapv2factory": "',
                vm.toString(address(uniswapv2factory)),
                '"}'
            )
        );
        vm.writeJson(data, path);

        vm.stopBroadcast();
    }
}

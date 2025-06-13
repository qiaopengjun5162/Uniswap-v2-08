// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console2} from "forge-std/Script.sol";
import {WETH9} from "../src/WETH9.sol";

contract WETH9Script is Script {
    WETH9 public weth9;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console2.log("Deploying contracts with the account:", deployerAddress);
        vm.startBroadcast(deployerPrivateKey);

        weth9 = new WETH9();
        console2.log("WETH9 deployed to:");
        console2.log(address(weth9));

        string memory path = "./deployments/WETH9.json";
        string memory data = string(
            abi.encodePacked(
                '{"deployerAddress": "',
                vm.toString(address(deployerAddress)),
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

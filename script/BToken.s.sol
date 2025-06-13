// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {BToken} from "../src/BToken.sol";

contract BTokenScript is Script {
    BToken public bToken;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with the account:", deployerAddress);
        vm.startBroadcast(deployerPrivateKey);

        bToken = new BToken(deployerAddress);
        console.log("BToken deployed to:", address(bToken));

        string memory path = "./deployments/BToken.json";
        string memory data = string(
            abi.encodePacked(
                '{"deployerAddress": "',
                vm.toString(address(deployerAddress)),
                '", ',
                '"BToken": "',
                vm.toString(address(bToken)),
                '"}'
            )
        );
        vm.writeJson(data, path);

        vm.stopBroadcast();
    }
}

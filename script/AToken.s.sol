// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {AToken} from "../src/AToken.sol";

contract ATokenScript is Script {
    AToken public aToken;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with the account:", deployerAddress);
        vm.startBroadcast(deployerPrivateKey);

        aToken = new AToken(deployerAddress);
        console.log("AToken deployed to:", address(aToken));

        string memory path = "./deployments/AToken.json";
        string memory data = string(
            abi.encodePacked(
                '{"deployerAddress": "',
                vm.toString(address(deployerAddress)),
                '", ',
                '"AToken": "',
                vm.toString(address(aToken)),
                '"}'
            )
        );
        vm.writeJson(data, path);

        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {UniswapV2Pair} from "../src/UniswapV2Pair.sol";
import {ERC20Mintable} from "../src/ERC20Mintable.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";

contract UniswapV2PairTest is Test {
    UniswapV2Pair public pair;
    UniswapV2Factory public uniswapv2factory;
    ERC20Mintable token0;
    ERC20Mintable token1;

    Account public owner = makeAccount("owner");
    Account public tokenA = makeAccount("tokenA");
    Account public tokenB = makeAccount("tokenB");
    Account public user = makeAccount("user");

    function setUp() public {
        uniswapv2factory = new UniswapV2Factory(owner.addr);
        pair = new UniswapV2Pair();

        vm.startPrank(tokenA.addr);
        token0 = new ERC20Mintable(tokenA.addr, "Token A", "TKNA");
        token0.approve(tokenA.addr, 100 ether);
        token0.mint(tokenA.addr, 10 ether);
        vm.stopPrank();
        vm.startPrank(tokenB.addr);
        token1 = new ERC20Mintable(tokenB.addr, "Token B", "TKNB");
        token1.approve(tokenB.addr, 100 ether);
        token1.mint(tokenB.addr, 10 ether);
        vm.stopPrank();
    }

    function testCreatePair() public {
        uniswapv2factory.createPair(address(token0), address(token1));
        address pairAddress = uniswapv2factory.getPair(address(token0), address(token1));
        assertEq(uniswapv2factory.allPairsLength(), 1);
        require(pairAddress != address(0), "Pair address is zero");
    }

    function testMintBootstrap() public {
        // 1. Create pair
        testCreatePair();
        assertEq(uniswapv2factory.allPairsLength(), 1);

        // 2. Transfer tokens
        vm.prank(tokenA.addr);
        token0.transfer(address(pair), 1 ether);

        vm.prank(tokenB.addr);
        token1.transfer(address(pair), 1 ether);

        assertEq(token0.balanceOf(address(pair)), 1 ether);
        assertEq(token1.balanceOf(address(pair)), 1 ether);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {UniswapV2Router02} from "../src/UniswapV2Router02.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {UniswapV2Pair} from "../src/UniswapV2Pair.sol";
import {WETH9} from "../src/WETH9.sol";
import {ERC20Mintable} from "../src/ERC20Mintable.sol";
import {MyDex} from "../src/MyDex/MyDex.sol";
import "../src/interfaces/IERC20.sol";
import {UniswapV2Library} from "../src/libraries/UniswapV2Library.sol";

contract UniswapV2Router02Test is Test {
    UniswapV2Router02 public uniswapv2router02;
    UniswapV2Factory public uniswapv2factory;
    ERC20Mintable token0;
    ERC20Mintable token1;
    WETH9 public weth;
    MyDex public mydex;

    Account public owner = makeAccount("owner");
    Account public user = makeAccount("user");
    Account public tokenA = makeAccount("tokenA");
    Account public tokenB = makeAccount("tokenB");

    function setUp() public {
        weth = new WETH9();

        uniswapv2factory = new UniswapV2Factory(owner.addr);
        uniswapv2router02 = new UniswapV2Router02(address(uniswapv2factory), address(weth));

        vm.startPrank(tokenA.addr);
        token0 = new ERC20Mintable(tokenA.addr, "Token A", "TKNA");
        token0.approve(tokenA.addr, 100 ether);
        token0.mint(tokenA.addr, 10 ether);
        token0.transfer(user.addr, 1 ether);
        vm.stopPrank();
        vm.startPrank(tokenB.addr);
        token1 = new ERC20Mintable(tokenB.addr, "Token B", "TKNB");
        token1.approve(tokenB.addr, 100 ether);
        token1.mint(tokenB.addr, 10 ether);
        token1.transfer(user.addr, 1 ether);
        vm.stopPrank();

        mydex = new MyDex(address(uniswapv2router02));
    }

    function testAddLiquidity() public {
        vm.startPrank(user.addr);
        assertEq(token0.balanceOf(address(user.addr)), 1 ether);
        assertEq(token1.balanceOf(address(user.addr)), 1 ether);
        token0.approve(address(uniswapv2router02), 1 ether);
        token1.approve(address(uniswapv2router02), 1 ether);

        (uint256 amountA, uint256 amountB, uint256 liquidity) = uniswapv2router02.addLiquidity(
            address(token0), address(token1), 1 ether, 1 ether, 1 ether, 1 ether, user.addr, block.timestamp + 1000
        );
        assertEq(amountA, 1 ether);
        assertEq(amountB, 1 ether);
        assertEq(liquidity, 1 ether - 1000);
        assertEq(token0.balanceOf(address(user.addr)), 0);
        assertEq(token1.balanceOf(address(user.addr)), 0);

        vm.stopPrank();
    }

    function testRemoveLiquidity() public {
        testAddLiquidity();

        vm.startPrank(user.addr);
        assertEq(token0.balanceOf(address(user.addr)), 0);
        assertEq(token1.balanceOf(address(user.addr)), 0);
        token0.approve(address(uniswapv2router02), 1 ether);
        token1.approve(address(uniswapv2router02), 1 ether);

        address pair = UniswapV2Library.pairFor(address(uniswapv2factory), address(token0), address(token1));
        IERC20 pairToken = IERC20(pair);
        uint256 lpBalance = pairToken.balanceOf(address(user.addr));
        pairToken.approve(address(uniswapv2router02), lpBalance);

        (uint256 amountA, uint256 amountB) = uniswapv2router02.removeLiquidity(
            address(token0), address(token1), 1e18 - 1000, 1e18 - 1000, 1e18 - 1000, user.addr, block.timestamp
        );

        assertEq(amountA, 1 ether - 1000);
        assertEq(amountB, 1 ether - 1000);
        assertEq(UniswapV2Pair(pair).totalSupply(), 1000);

        vm.stopPrank();
    }

    function testSellETH() public {
        uint256 amountIn = 2 ether;
        uint256 exceptMinToken = 1 ether;

        // 1. add liquidity
        _addLiquidityETH();
        assertEq(token0.balanceOf(address(this)), 0);
        uint256 beforeBalance = address(this).balance;
        // 2. sell ETH
        mydex.sellETH{value: amountIn}(address(token0), exceptMinToken);

        uint256 afterBalance = address(this).balance;
        assertLe(afterBalance, 79228162492264337593543950335);
        assertEq(beforeBalance, 79228162494264337593543950335);

        assertEq(token0.balanceOf(address(user.addr)), 1 ether);
        assertEq(token0.balanceOf(address(this)), 1662497915624478906);
    }

    function testbuyETH() public {
        uint256 amountIn = 1e18;
        // 1. add liquidity
        _addLiquidityETH();
        // 2. mint token0
        vm.prank(tokenA.addr);
        token0.mint(address(this), 10 ether);
        // 2. buy ETH
        token0.approve(address(mydex), amountIn);

        // 创建一个address类型的数组path，长度为2
        address[] memory path = new address[](2);
        // 将token0的地址赋值给path[0]
        path[0] = address(token0);
        // 将weth的地址赋值给path[1]
        path[1] = address(weth);
        // 调用UniswapV2Router02的getAmountsOut方法，获取amountOutETH
        uint256[] memory amountOuts = uniswapv2router02.getAmountsOut(amountIn, path);
        // 将amountOutETH赋值给amountOutETH
        uint256 amountOutETH = amountOuts[path.length - 1];
        // 计算exceptMinETH
        uint256 exceptMinETH = (amountOutETH * 99) / 100;
        uint256 beforeBalance = address(this).balance;
        mydex.buyETH(address(token0), amountIn, exceptMinETH);
        uint256 afterBalance = address(this).balance;
        assertGe(afterBalance, beforeBalance + exceptMinETH, "buy ETH failed");
    }

    function _addLiquidityETH() public {
        weth.deposit{value: 10 ether}();
        vm.prank(tokenA.addr);
        token0.mint(address(this), 10 ether);

        token0.approve(address(uniswapv2router02), 10e18);

        // 1. add liquidity
        (uint256 amountToken, uint256 amountETH, uint256 liquidity) = uniswapv2router02.addLiquidityETH{value: 10 ether}(
            address(token0), 10 ether, 1 ether, 1 ether, user.addr, block.timestamp
        );
        assertEq(amountToken, 10 ether);
        assertEq(amountETH, 10 ether);
        assertEq(liquidity, 10 ether - 1000);
    }

    receive() external payable {}
}

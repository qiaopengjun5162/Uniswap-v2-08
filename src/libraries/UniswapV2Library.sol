// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "../interfaces/IUniswapV2Pair.sol";
import "./SafeMath.sol";
import "../UniswapV2Pair.sol";
import {Test, console} from "forge-std/Test.sol";

library UniswapV2Library {
    // using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        // bytes32 hash = keccak256(abi.encodePacked(bytecode));
        bytes32 hash = keccak256(
            abi.encodePacked(
                hex"ff", factory, keccak256(abi.encodePacked(token0, token1)), keccak256(abi.encodePacked(bytecode))
            )
        );
        // hex"0xd59a4b7a3d30d8afd9bba1a80fac80da0785face48d391ee6bc9535a907f0e0e" // init code hash
        // 直接从 bytes32 类型转换为 address 类型
        pair = address(uint160(uint256(hash)));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB)
        internal
        view
        returns (uint256 reserveA, uint256 reserveB)
    {
        (address token0,) = sortTokens(tokenA, tokenB);

        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();

        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) internal pure returns (uint256 amountB) {
        require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        // amountB = amountA.mul(reserveB) / reserveA;
        amountB = (amountA * reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountOut)
    {
        // 检查输入金额是否大于0
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        // 检查储备金额是否大于0
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        // 计算费用的输入金额 0.997
        // uint256 amountInWithFee = amountIn.mul(997);
        uint256 amountInWithFee = amountIn * 997;
        // 计算分子
        uint256 numerator = amountInWithFee * reserveOut;
        // 计算分母
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        // 计算输出金额
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountIn)
    {
        // 确保输出金额大于0
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        // 确保池子中的资产数量大于0
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        // 计算分子
        uint256 numerator = reserveIn * amountOut * 1000;
        // 计算分母
        uint256 denominator = reserveOut - amountOut * 997;
        // 计算输入金额
        amountIn = (numerator / denominator) + 1;
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint256 amountIn, address[] memory path)
        internal
        view
        returns (uint256[] memory amounts)
    {
        // 确保路径长度大于等于2
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        // 创建一个uint256数组，长度为路径长度
        amounts = new uint256[](path.length);
        // 第一个地址为输入金额
        amounts[0] = amountIn;
        // 遍历路径数组
        for (uint256 i; i < path.length - 1; i++) {
            // 获取第i个地址和第i+1个地址的储备量
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
            // 计算第i+1个地址的输出金额
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint256 amountOut, address[] memory path)
        internal
        view
        returns (uint256[] memory amounts)
    {
        // 确保路径长度大于等于2
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        // 创建一个uint256数组，长度为路径长度
        amounts = new uint256[](path.length);
        // 把amountOut赋值给数组的最后一个元素
        amounts[amounts.length - 1] = amountOut;
        // 从路径的最后一个元素开始遍历 倒序
        for (uint256 i = path.length - 1; i > 0; i--) {
            // 获取factory，path[i - 1]，path[i]的储备量
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i - 1], // 倒数第二个
                path[i]
            );
            // 输入数额就是下一个的输出数额 由后往前 计算
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IUniswapV2Factory.sol";
import "./UniswapV2Pair.sol";
import {Script, console} from "forge-std/Script.sol";

contract UniswapV2Factory is IUniswapV2Factory {
    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES");
        // 用于交换两个地址的值的，根据地址tokenA和tokenB的大小关系来决定交换的顺序。
        // 如果tokenA在tokenB之前，那么它们将被交换。否则，它们将保持不变。
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), "UniswapV2: PAIR_EXISTS"); // single check is sufficient
        //  用于获取 UniswapV2Pair 合约的创建字节码。这是一个智能合约编译器生成的字节码，用于在部署合约时初始化合约的代码。
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 hash = keccak256(abi.encodePacked(bytecode));
        console.logBytes32("hash: ");
        console.logBytes32(hash);
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        // CREATE2 是以太坊虚拟机 (EVM) 引入的一个 opcode，用于在智能合约中创建新合约。
        // 与传统的 CREATE opcode 不同，CREATE2 允许合约部署者在合约创建时指定合约地址，这样就可以预先知道新合约的地址。
        // CREATE2 是在以太坊硬分叉 Istanbul (EIP-1014) 中引入的。
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUniswapV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }
}

# Uniswap V2 学习笔记

## 1. Uniswap V2 概述

### 1.1 Uniswap V2 介绍

Uniswap V2 是一种去中心化的交易所（DEX），它允许用户在没有中介的情况下交换 ERC20 代币。Uniswap V2 的核心是一个自动做市商（AMM），它使用一种称为恒定乘积公式（Constant Product Formula）的数学模型来管理代币池。

### 1.2 Uniswap V2 的特点

- 去中心化：Uniswap V2 是完全去中心化的，用户不需要信任任何第三方。
- 自动做市商：Uniswap V2 使用自动做市商（AMM）模型，用户不需要提供流动性。
- 透明度：Uniswap V2 的交易和流动性提供都是公开透明的，用户可以随时查看交易历史和流动性池的状态。
- 安全性：Uniswap V2 的智能合约代码已经过审计，并且使用了多种安全措施来防止攻击。

### 1.3 Uniswap V2 的架构

Uniswap V2 的架构包括以下几个部分：智能合约、前端界面和后端服务。

- 智能合约：Uniswap V2 的核心是智能合约，它定义了代币池的规则和交易逻辑。智能合约使用 Solidity 编写，并部署在以太坊区块链上。
- 前端界面：Uniswap V2 的前端界面是一个用户友好的界面，用户可以在上面进行交易和流动性提供。前端界面可以使用任何支持以太坊的浏览器插件，如 MetaMask。

## 源码分析

UniswapV2Pair 继承了 UniswapV2ERC20

UniswapV2Factory 是用来部署 UniswapV2Pair 的工厂合约

每一个交易对都是在 pair 合约里面进行锁定的，进行对标的
每一个 pair 合约都继承了一些 ERC20 的方法
UniswapV2Pair + UniswapV2ERC20 是一个配对合约

UniswapV2Router01 UniswapV2Router02
为什么要有两个路由合约？
因为如果把两个合约都放到一个合约里面，会导致合约过大，无法部署到以太坊上
gas费超了，超过了最多允许的800万了，所以要分成两个合约

## 2. Uniswap V2 的交易逻辑

### 2.1 添加流动性

添加流动性是指用户将两种代币放入一个代币池中，以换取流动性代币。流动性代币代表用户在代币池中的份额，用户可以通过燃烧流动性代币来提取相应的代币。

### 2.2 移除流动性

移除流动性是指用户燃烧流动性代币，以提取相应的代币。移除流动性的数量取决于用户在添加流动性时所占的份额。

### 路由合约

- <https://etherscan.io/address/0x7a250d5630b4cf539739df2c5dacb4c659f2488d#code>

### WETH9

- <https://etherscan.io/address/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#code>

### UniswapV2Factory

- <https://etherscan.io/address/0x5c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f#code>

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IUniswapV2Router02.sol";

contract MyDex {
    using SafeERC20 for IERC20;

    IUniswapV2Router02 public uniswapRouter;

    constructor(address _uniswapRouter) {
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
    }

    /**
     * @dev 卖出ETH，兑换成 buyToken
     * @param buyToken 兑换的目标代币地址
     * @param minBuyAmount 要求最低兑换到的 buyToken 数量
     */
    function sellETH(address buyToken, uint256 minBuyAmount) external payable {
        require(msg.value > 0, "Must send ETH to sell");
        require(minBuyAmount > 0, "Min buy amount must be greater than 0");
        require(buyToken != address(0), "Buy token address must not be zero");

        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = buyToken;

        uniswapRouter.swapExactETHForTokens{value: msg.value}(minBuyAmount, path, msg.sender, block.timestamp + 1000);
    }

    /**
     * @dev 买入ETH，用 sellToken 兑换
     * @param sellToken 出售的代币地址
     * @param sellAmount 出售的代币数量
     * @param minBuyAmount 要求最低兑换到的ETH数量
     */
    function buyETH(address sellToken, uint256 sellAmount, uint256 minBuyAmount) external {
        require(sellAmount > 0, "Must specify amount to sell");
        // 1. 检查 sellToken 地址是否有效
        require(sellToken != address(0), "Sell token address must not be zero");
        // 2. 检查 minBuyAmount 是否大于0
        require(minBuyAmount > 0, "Min buy amount must be greater than 0");

        // 3. 检查 sellToken 是否是 ERC20 代币
        IERC20(sellToken).approve(address(uniswapRouter), sellAmount);

        // 4. 检查 sellToken 的余额是否足够
        require(IERC20(sellToken).balanceOf(msg.sender) >= sellAmount, "Insufficient sell token balance");
        // 5. 从 msg.sender 转移 sellAmount 的 sellToken 到合约
        IERC20(sellToken).safeTransferFrom(msg.sender, address(this), sellAmount);

        address[] memory path = new address[](2);
        path[0] = sellToken;
        path[1] = uniswapRouter.WETH();
        // 6. Token 授权给 Uniswap Router 合约
        // IERC20(sellToken).approve(address(uniswapRouter), sellAmount);
        // 如果没有足额的授权，则进行一次最大额度的授权
        if (IERC20(sellToken).allowance(address(this), address(uniswapRouter)) < sellAmount) {
            IERC20(sellToken).approve(address(uniswapRouter), type(uint256).max);
        }
        // 7. 调用 Uniswap Router 合约的 swapExactTokensForETH 函数，将 sellToken 换成 ETH
        uniswapRouter.swapExactTokensForETH(sellAmount, minBuyAmount, path, msg.sender, block.timestamp);
    }

    // 提取合约中的 ETH
    function withdrawETH() external {
        payable(msg.sender).transfer(address(this).balance);
    }

    // 提取合约中的代币
    function withdrawTokens(address tokenAddress) external {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        token.safeTransfer(msg.sender, balance);
    }
}

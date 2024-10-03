// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Implement Uniswap swap interface
// Implement library to help with token transfers

// Import the Uniswap V3 interface
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

// Import the library to help with token transfers (Uniswap v3)
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleTokenSwapper {
    ISwapRouter public immutable swapRouter;
    address public immutable WETH;

    // Define the constructor
    constructor(ISwapRouter _swapRouter, address _weth) {
        swapRouter = _swapRouter;
        WETH = _weth;
    }

    // Swap function that takes input token, output token, input amount, min output amount, and recipient
    function swap(
        address tokenIn, // The input token address (e.g., USDC)
        address tokenOut, // The output token address (e.g., WETH)
        uint256 amountIn, // The input token amount
        uint256 amountOutMinimum, // The minimum acceptable output amount
        address recipient // Address that will receive the output tokens
    ) external returns (uint256 amountOut) {
        // Transfer input tokens from the sender to this contract
        TransferHelper.safeTransferFrom(
            tokenIn,
            msg.sender,
            address(this),
            amountIn
        );

        // Approve the Uniswap router to spend the input tokens
        TransferHelper.safeApprove(tokenIn, address(swapRouter), amountIn);

        // Define the Uniswap V3 swap parameters
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn, // Input token
                tokenOut: tokenOut, // Output token
                fee: 3000, // Pool fee for Uniswap (0.3%)
                recipient: recipient, // Where to send the output tokens
                deadline: block.timestamp + 15, // Transaction deadline (15 seconds)
                amountIn: amountIn, // Amount of input token
                amountOutMinimum: amountOutMinimum, // Minimum acceptable output amount
                sqrtPriceLimitX96: 0 // No price limit
            });

        // Execute the swap on Uniswap and return the output amount
        amountOut = swapRouter.exactInputSingle(params);
    }
}

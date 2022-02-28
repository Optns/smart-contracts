// // SPDX-License-Identifier: GPL-2.0-or-later
// pragma solidity =0.7.6;
// pragma abicoder v2;

// import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
// import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

// contract SwapExamples {

//     uint24 public constant poolFee = 3000;

//     constructor() {
//     }
//     function swapExactInputSingle(uint256 amountIn, address tokenIn, address tokenOut) external returns (uint256 amountOut) {

//         TransferHelper.safeTransferFrom(amountIn, msg.sender, address(this), amountIn);

//         TransferHelper.safeApprove(amountIn, address(swapRouter), amountIn);

//         ISwapRouter.ExactInputSingleParams memory params =
//             ISwapRouter.ExactInputSingleParams({
//                 tokenIn: tokenIn,
//                 tokenOut: tokenOut,
//                 fee: poolFee,
//                 recipient: msg.sender,
//                 deadline: block.timestamp,
//                 amountIn: amountIn,
//                 amountOutMinimum: 0,
//                 sqrtPriceLimitX96: 0
//             });

//         amountOut = swapRouter.exactInputSingle(params);
//     }

//     function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum, address tokenIn, address tokenOut) external returns (uint256 amountIn) {
//         TransferHelper.safeTransferFrom(amountIn, msg.sender, address(this), amountInMaximum);

//         TransferHelper.safeApprove(amountIn, address(swapRouter), amountInMaximum);

//         ISwapRouter.ExactOutputSingleParams memory params =
//             ISwapRouter.ExactOutputSingleParams({
//                 tokenIn: amountIn,
//                 tokenOut: tokenOut,
//                 fee: poolFee,
//                 recipient: msg.sender,
//                 deadline: block.timestamp,
//                 amountOut: amountOut,
//                 amountInMaximum: amountInMaximum,
//                 sqrtPriceLimitX96: 0
//             });

//         amountIn = swapRouter.exactOutputSingle(params);

//         if (amountIn < amountInMaximum) {
//             TransferHelper.safeApprove(tokenIn, address(swapRouter), 0);
//             TransferHelper.safeTransfer(tokenIn, msg.sender, amountInMaximum - amountIn);
//         }
//     }
// }
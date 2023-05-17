// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IUniswapV3SwapCallback.sol";
import "./interfaces/IUniswapV3Pool.sol";
import "./interfaces/IERC20.sol";


contract MySwap is IUniswapV3SwapCallback {

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address private owner;

    struct ExactInput {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    struct SwapCallbackData {
        address[] pool;
        // always true, tokenA < tokenB
        // true = tokenA -> tokenB
        // false = tokenB -> tokenA
        bool direction;
    }

    constructor() {
        owner = msg.sender;
    }
    // pool has tokens with tokenA and tokenB
    // always true => tokenA < tokenB
    // addr[0] = pool
    // addr[1] = fromToken
    // addr[2] = toToken
    // this function swaps from tokenA -> tokenB
    function directSwap(address[] calldata addr, int256 amountIn, int256 min) public {
        (, int256 amount1) = IUniswapV3Pool(addr[0]).swap(
            address(this),
            true,
            amountIn,
            0,
            abi.encode(SwapCallbackData({pool: addr, direction:true})));

        require(amount1 >= min);
    }

    //this function swaps from tokenB -> tokenA
    function inverseSwap(address[] calldata addr, int256 amountIn, int256 min) public {
        (int256 amount0, ) = IUniswapV3Pool(addr[0]).swap(
            address(this),
            true,
            amountIn,
            0,
            abi.encode(SwapCallbackData({pool: addr, direction:true})));
        require(amount0 >= min);
    }


    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata _data) external {
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        require(msg.sender == data.pool[0]);
        require(amount0Delta > 0 || amount1Delta > 0);

        if (data.direction) {
            // pay tokenA
            IERC20(data.pool[1]).transfer(data.pool[1], amount0Delta)
        } else {
            // pay tokenB
            IERC20(data.pool[1]).transfer(data.pool[2], amount1Delta)
        }
        
    }

    function depositToken(address token) public onlyOwner  {

    }

    function withdrawToken() public onlyOwner {

    }

    function depositETH() public onlyOwner {

    }
    function withDrawETH() public onlyOwner{

    }

    function approveToken() public onlyOwner{

    }
}

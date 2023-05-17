// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IUniswapV3SwapCallback.sol";
import "./interfaces/IUniswapV3Pool.sol";
import "./interfaces/IERC20.sol";


contract MySwap is IUniswapV3SwapCallback {

    modifier onlyOwner() {
        require(msg.sender == owner, "0");
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
        address[] addrList;
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
            4295128740,
            abi.encode(SwapCallbackData({addrList: addr, direction:true})));
        require(-amount1 >= min, "1");
    }

    //this function swaps from tokenB -> tokenA
    function inverseSwap(address[] calldata addr, int256 amountIn, int256 min) public {
        (int256 amount0, ) = IUniswapV3Pool(addr[0]).swap(
            address(this),
            true,
            amountIn,
            0,
            abi.encode(SwapCallbackData({addrList: addr, direction:true})));
        require(-amount0 >= min, "2");
    }


    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata _data) external {
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        require(msg.sender == data.addrList[0], "3");
        require(amount0Delta > 0 || amount1Delta > 0, "4");

        if (data.direction) {
            // pay token0
            IERC20(data.addrList[1]).transfer(data.addrList[0], uint256(amount0Delta));
        } else {
            // pay token1
            IERC20(data.addrList[1]).transfer(data.addrList[0], uint256(amount1Delta));
        }
    }

    function depositToken(address token, uint256 amount) public onlyOwner  {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
    }

    function withdrawToken(address token) public onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, balance);
    }
}

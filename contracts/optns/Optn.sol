//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IERC20.sol";

struct Optn {
    uint256 durationInBlock;
    uint256 premium;
    int strikePrice;
    uint256 amount;
    IERC20 token;
}

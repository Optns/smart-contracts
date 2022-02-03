//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";

struct Optn {
    uint256 durationInBlock;
    uint256 premium;
    int strikePrice;
    uint256 amount;
}

struct Order {
    Optn optn;
    address seller;
    address buyer;
    uint256 initializationBlock;
}
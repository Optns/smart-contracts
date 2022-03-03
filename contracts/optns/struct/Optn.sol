//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './../interface/IERC20.sol';
import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';

struct Optn {
    uint256 premium;
    int256 strikePrice;
}

struct Order {
    Optn optn;
    address seller;
    address buyer;
    uint256 initializationBlock;
}

struct OrderBookStandard {
    address implementation;
    address baseCurrency;
    address token;
    uint256 amount;
    uint256 durationInBlock;
}

enum OptionType {PUT, CALL}
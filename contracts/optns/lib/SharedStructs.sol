//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SharedStructs {
    enum Duration {
        HOUR, DAY, WEEK, MONTH, YEAR
    }

    struct OrderbookStandard {
        address implementation;
        address tokenIn;
        address tokenOut;
        uint256 amountPow;
    }

    struct OptionStandard {
        address tokenIn;
        address tokenOut;
        uint256 amount;
    }

    struct Option {
        uint256 premium;
        uint256 strikePrice;
        Duration duration;
    }
}
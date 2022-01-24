//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
import "./../../IERC20.sol";

struct Optn {
    uint256 durationInBlock;
    uint256 premium;
    uint256 strikePrice;
    IERC20 token;
}

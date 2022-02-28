//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./../../Optn.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @dev Interface of IOption contract
 */
interface IOptionOrder {
    function order() external view returns (Order memory);

    function viewInitializationBlock() external view returns (uint256);
}

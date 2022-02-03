//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./../../Optn.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @dev Interface of IOption contract
 */
interface IOptionOrder {
    function viewOrder() external view returns(Order memory order);
    
    function viewInitializationBlock() external view returns(uint256);
}

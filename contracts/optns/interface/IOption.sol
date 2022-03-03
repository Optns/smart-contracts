//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './../struct/Optn.sol';
import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';

/**
 * @dev Interface of IOption contract
 */
interface IOption {
    function __option_init(Optn memory _optn, address _seller, address orderbook, OptionType optionType) external; 

    function order() external view returns (Order memory);

    function viewInitializationBlock() external view returns (uint256);

    function escrow(uint256) external;

    function terminate() external;

    function payPremium() external;

    function expire() external;
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './../struct/Optn.sol';
import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';

/**
 * @dev Interface of IOption contract
 */
interface IOption {
    function __option_init(Optn memory _optn, address _seller, address orderbook, OptionType optionType) external; 

    function getSeller() external view returns (address);
    
    function getBuyer() external view returns (address);

    function getOrder() external view returns (Order memory);

    function getStatus() external view returns(Status);

    function escrow() external;

    function cancel() external;

    function buy() external;

    function expire() external;
}

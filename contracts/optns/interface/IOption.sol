//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import './../lib/SharedStructs.sol';

/**
 * @dev Interface of IOption contract
 */
interface IOption {
    enum Status {
        INIT, ESCROWED, BOUGHT, CLOSED 
    }

    function __option_init(SharedStructs.Option memory option, address seller, SharedStructs.OptionStandard memory optionStandard) external; 

    function getSeller() external view returns (address seller);
    
    function getBuyer() external view returns (address buyer);

    function getOrder() external view returns (SharedStructs.Option memory);

    function getStatus() external view returns(Status);

    function getExpiryTimestamp() external view returns(uint256 expiry);

    function getOptionStandard() external view returns (SharedStructs.OptionStandard memory optionStandard);

    function escrow() external;

    function cancel() external;

    function buy() external;

    function expire() external;

    function execute() external;
}

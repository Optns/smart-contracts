//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './../lib/SharedStructs.sol';

interface IOptionFactory {

    function __optionFactory_init() external;

    function getOrderbookStandard() external returns(SharedStructs.OrderbookStandard memory orderbookStandard);

    function updateOwner(address owner) external;

    function updateOrderBookStandard(SharedStructs.OrderbookStandard memory orderBookStandard) external;

    function cloneOptionContract(SharedStructs.Option memory option) external;
}

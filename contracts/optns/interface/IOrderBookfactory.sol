//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './../lib/SharedStructs.sol';

interface IOrderBookFactory {

    function __orderBookFactory_init(address optionFactory) external;

    function getGov() external returns(address gov);

    function getMarketAddress(bytes32 pairHash) external returns(address marketAddress);

    function changeGov(address gov) external;

    function getOptionFactory() external returns(address optionFactory);

    function changeOptionFactory(address optionFactoryAddress) external;

    function updateOrderBookStandard(
        SharedStructs.OrderbookStandard memory orderbookStandard,
        address orderbookAddress) external;

    function createMarket(SharedStructs.OrderbookStandard memory orderbookStandard) external;
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './../lib/SharedStructs.sol';

interface IOptionFactory {

    function __optionFactory_init() external;
    
    function updateOwner(address owner) external;

    function updateOrderBookStandard(SharedStructs.OrderbookStandard memory orderbookStandard) external;

    function cloneOptionContract(SharedStructs.Option memory option) external;
}

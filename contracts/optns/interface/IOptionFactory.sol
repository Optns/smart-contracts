//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './../struct/Optn.sol';

interface IOptionFactory {
    function __optionFactory_init(OrderBookStandard memory orderBookStandard) external;

    function getToken() external view returns (IERC20);

    function getBaseCurrency() external view returns (IERC20);

    function getAmount() external view returns (uint256);

    function getDurationInBlock() external view returns (uint256);

    function getOrderBookStandard() external view returns (OrderBookStandard memory);

    function cloneOptionContract(Optn memory optn, address seller, OptionType optionType) external;
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./../struct/Optn.sol";

interface ISellOptionOrder {
    function __sellOption_init(
        Optn memory optn,
        address seller,
        address orderbook
    ) external;

    function escrow(uint256) external;

    function terminate() external;

    function payPremium() external;

    function expire() external;

    function execute() external;
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./../../Optn.sol";

interface ISellOptionOrder {

    function __sellOption_init(Optn memory optn, address usdAddress, address oracle, address tokenAddress, address seller) external;

    function escrowFunds(uint256) external;

    function terminateContract() external;

    function payPremium() external;

    function expireContract() external;
    
    function executeOption() external;
}
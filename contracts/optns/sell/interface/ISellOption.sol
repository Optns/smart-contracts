//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ISellOption {
    function escrowFunds(uint256) external;

    function terminateContract() external;

    function payPremium() external;

    function expireContract() external;
    
    function executeOption() external;
}
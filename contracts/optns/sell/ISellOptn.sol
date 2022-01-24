//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./structures/Optn.sol";

/**
 * @dev Interface of ISellOptn contract
 */
interface ISellOptn {
    function viewOptn() external view returns(Optn memory optn);

    function escrowFunds(uint256) external returns(bool);

    function terminateContract() external returns(bool);

    function payPremium() external returns(bool);

    function expireContract() external returns(bool);

    function executeOptn() external returns(bool);
}

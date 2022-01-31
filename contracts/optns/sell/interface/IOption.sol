//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./../../Optn.sol";

/**
 * @dev Interface of IOption contract
 */
interface IOption {
    function viewOptn() external view returns(Optn memory optn);
}

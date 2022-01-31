//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./interface/IOption.sol";
import "./../utils/Access.sol";
import "./../Optn.sol";

/**
 * @dev Implementation of the {IOptn} interface.
 */
contract Option is IOption, Access {
    
    Optn internal optn;
    uint256 internal initializationBlock;

    constructor(Optn memory option) Access() {
        optn = option;
        initializationBlock = 0;
    }

    event Deposit(address indexed _contract, address indexed _from,  address indexed _to, uint256 _amount);
    event Withdraw(address indexed _contract, address indexed _to, uint256 _amount);

    function viewOptn() external override view returns(Optn memory) {
        return optn;
    }

    function viewInitializationBlock() external view returns(uint256){
        return initializationBlock;
    }

    function initializeBlock() internal {
        initializationBlock = block.number;
    }
    
    function withdraw(address to, uint256 amount, IERC20 token) internal returns(bool) {
        token.transfer(to, amount);
        emit Withdraw(address(this), to, amount);
        return true;
    }

    function deposit(address from, address to, uint256 amount, IERC20 token) internal returns(bool) {
        uint256 allowance = token.allowance(from, address(this));
        require(allowance >= amount, "Permission: Allowance != amount");

        token.transferFrom(from, to, amount);
        emit Deposit(address(this), from, to, amount);
        return true;
    }
}

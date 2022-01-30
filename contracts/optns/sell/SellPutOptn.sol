//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./ISellOptn.sol";
import "./structures/Optn.sol";
import "./../utils/Access.sol";

/**
 * @dev Implementation of the {ISellOptn} interface.
 */
contract SellPutOptn is ISellOptn, Access {
    Optn private _optn;
    uint256 private _initializationBlock;
    IERC20 private _gasToken; 

    constructor(Optn memory optn) {
        _optn = optn;
    }

    event Deposit(address indexed _contract, address indexed _from,  address indexed _to, uint256 _amount);
    event Withdraw(address indexed _contract, address indexed _to, uint256 _amount);

    function viewOptn() external override view returns(Optn memory optn) {
        return _optn;
    }

    function setGasToken(address gasTokenAddress) external onlySeller {
        _gasToken = IERC20(gasTokenAddress);
    }

    function escrowFunds(uint256 amount) external override onlySeller returns(bool) {
        require(amount > 0, "Amount: amount should be > 0");
        bool response = _deposit(msg.sender, address(this), amount, _optn.token);
        return response;
    }

    function terminateContract() external override onlySeller onlyNullBuyer returns(bool) {
        uint256 contractBalance = _optn.token.balanceOf(address(this));
        require(contractBalance > 0, "Balance: zero balance in contract");
        bool response = _withdraw(_seller, contractBalance);
        return response;
    }

    function payPremium() external override onlyNullBuyer returns(bool) {
        bool deposited = _deposit(msg.sender, _seller, _optn.premium, _gasToken);
        require(deposited == true);
        setBuyer();
        _initializeBlock();
        return true;
    }

    function sender() external view returns(address) {
        return msg.sender;
    }

    function expireContract() external override onlySeller returns(bool) {
        require(_optn.durationInBlock < block.number - _initializationBlock);
        uint256 contractBalance = _optn.token.balanceOf(address(this));
        require(contractBalance > 0, "Balance: zero balance in contract");
        bool response = _withdraw(_seller, contractBalance);
        return response;
    }

    function executeOptn() external override view onlyBuyer returns(bool) {
        // calculate profit
        return true;
    }

    function _initializeBlock() private {
        _initializationBlock = block.number;
    }
    
    function _withdraw(address to, uint256 amount) private returns(bool) {
        _optn.token.transfer(to, amount);
        emit Withdraw(address(this), to, amount);
        return true;
    }

    function _deposit(address from, address to, uint256 amount, IERC20 token) private returns(bool) {
        uint256 allowance = token.allowance(from, address(this));
        require(allowance >= amount, "Permission: Allowance != amount");

        token.transferFrom(from, to, amount);
        emit Deposit(address(this), from, to, amount);
        return true;
    }
}

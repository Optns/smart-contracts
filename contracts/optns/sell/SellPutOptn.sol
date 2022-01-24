//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./ISellOptn.sol";
import "./structures/Optn.sol";
import "./../utils/Access.sol";

/**
 * @dev Implementation of the {ISellOptn} interface.
 */
contract SellPutOptn is ISellOptn, Access {
    Optn _optn;
    uint256 _initializationBlock;

    constructor(Optn memory optn) {
        _optn = optn;
    }

    event Deposit(address indexed _contract, address indexed _from,  address indexed _to, uint256 _amount);
    event Withdraw(address indexed _contract, address indexed _to, uint256 _amount);

    function viewOptn() public view returns(Optn memory optn) {
        return _optn;
    }

    function escrowFunds(uint256 amount) external onlySeller returns(bool) {
        require(amount > 0, "Amount: amount should be > 0");
        bool response = _deposit(msg.sender, address(this), amount);
        return response;
    }

    function terminateContract() external onlySeller onlyNullBuyer returns(bool) {
        uint256 contractBalance = _optn.token.balanceOf(address(this));
        require(contractBalance > 0, "Balance: balance=0 in stored ERC20 contract");
        bool response = _withdraw(_seller, contractBalance);
        return response;
    }

    function payPremium() external onlyNullBuyer returns(bool) {
        bool deposited = _deposit(msg.sender, _seller, _optn.premium);
        require(deposited == true);
        setBuyer();
        _initializeBlock();
        return true;
    }

    function expireContract() external onlySeller returns(bool) {
        require(_optn.durationInBlock < block.number - _initializationBlock);
        uint256 contractBalance = _optn.token.balanceOf(address(this));
        require(contractBalance > 0, "Balance: balance=0 in stored ERC20 contract");
        bool response = _withdraw(_seller, contractBalance);
        return response;
    }

    function _initializeBlock() private {
        _initializationBlock = block.number;
    }

    function executeOptn() external onlyBuyer {
        // calculate profit

    }
    
    function _withdraw(address to, uint256 amount) private returns(bool) {
        _optn.token.transfer(to, amount);
        emit Withdraw(address(this), to, amount);
        return true;
    }

    function _deposit(address from, address to, uint256 amount) private returns(bool) {
        bool approve = _optn.token.approve(address(this), amount);
        require(approve == true, "Permission: Spending access denied");

        uint256 allowance = _optn.token.allowance(from, address(this));
        require(allowance >= amount, "Permission: Allowance != amount");

        _optn.token.transferFrom(from, to, amount);
        emit Deposit(address(this), from, to, amount);
        return true;
    }
}

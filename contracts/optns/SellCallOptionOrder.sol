//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OptionOrder.sol";
import "./interface/ISellOptionOrder.sol";
import "./interface/ISellOptionFactory.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract SellCallOptionOrder is ISellOptionOrder, OptionOrder, Initializable {
    ISellOptionFactory private _orderbook;

    function __sellOption_init(
        Optn memory optn,
        address seller,
        address orderbook
    ) external override initializer {
        __option_init(optn, seller);
        _orderbook = ISellOptionFactory(orderbook);
    }

    function escrow(uint256 funds) external override onlySeller {
        require(funds > 0, "Amount: amount should be > 0");

        IERC20 baseCurrency = _orderbook.getBaseCurrency();

        deposit(msg.sender, address(this), funds, baseCurrency);
        emit Escrow(address(this), funds);
    }

    function terminate() external override onlySeller onlyNullBuyer {
        IERC20 baseCurrency = _orderbook.getBaseCurrency();
        uint256 contractBalance = baseCurrency.balanceOf(address(this));

        require(contractBalance > 0, "Balance: zero balance in contract");
        withdraw(seller, contractBalance, baseCurrency);
        emit Terminate(address(this));
    }

    function payPremium() external override onlyNullBuyer {
        IERC20 baseCurrency = _orderbook.getBaseCurrency();

        deposit(msg.sender, seller, optn.premium, baseCurrency);
        setBuyer();
        initializeBlock();
        emit Premium(address(this));
    }

    function expire() external override onlySeller {
        uint256 durationInBlock = _orderbook.getDurationInBlock();
        require(durationInBlock < block.number - initializationBlock);

        IERC20 baseCurrency = _orderbook.getBaseCurrency();

        uint256 contractBalance = baseCurrency.balanceOf(address(this));
        require(contractBalance > 0, "Balance: zero balance in contract");
        withdraw(seller, contractBalance, baseCurrency);
        emit Expire(address(this));
    }

    function execute() external override onlyBuyer {
        
    }
}

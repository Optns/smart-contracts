//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OptionOrder.sol";
import "./interface/ISellOptionOrder.sol";
import "./interface/ISellOptionFactory.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract SellPutOptionOrder is ISellOptionOrder, OptionOrder, Initializable {

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
        IERC20 token = _orderbook.getToken();
        deposit(msg.sender, address(this), funds, token);
        emit Escrow(address(this), funds);
    }

    function terminate() external override onlySeller onlyNullBuyer {
        IERC20 token = _orderbook.getToken();
        uint256 contractBalance = token.balanceOf(address(this));
        require(contractBalance > 0, "Balance: zero balance in contract");
        withdraw(seller, contractBalance, token);
        emit Terminate(address(this));
    }

    function payPremium() external override onlyNullBuyer {
        // check if contract have escrow
        IERC20 baseCurrency = _orderbook.getBaseCurrency();
        deposit(msg.sender, seller, optn.premium, baseCurrency);
        setBuyer();
        initializeBlock();
        emit Premium(address(this));
    }

    function expire() external override onlySeller {
        require(optn.durationInBlock < block.number - initializationBlock);
        IERC20 token = _orderbook.getToken();
        uint256 contractBalance = token.balanceOf(address(this));
        require(contractBalance > 0, "Balance: zero balance in contract");
        withdraw(seller, contractBalance, token);
        emit Expire(address(this));
    }

    function execute() external override onlyBuyer {
        int currentPrice = _orderbook.latestPrice();

        require(currentPrice > 0, "price lesser than zerp");
        require(currentPrice > optn.strikePrice, "current price lesser than strike price");

        IERC20 token = _orderbook.getToken();
        IERC20 baseCurrency = _orderbook.getBaseCurrency();
        
        uint256 contractBalance = token.balanceOf(address(this));
        uint256 value = optn.amount * uint(optn.strikePrice);
        
        deposit(buyer, seller, value, baseCurrency);
        withdraw(buyer, contractBalance, token);
        emit Execute(address(this));
    }
}
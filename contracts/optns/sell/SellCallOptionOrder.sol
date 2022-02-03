//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OptionOrder.sol";
import "./interface/ISellOptionOrder.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract SellCallOpttionOrder is ISellOptionOrder, OptionOrder, Initializable {

    IERC20 private _baseCurrency; 
    IERC20 private _token;
    AggregatorV3Interface private _priceFeed;

    function __sellOption_init(
        Optn memory optn,
        address baseCurrency,
        address oracle,
        address tokenAddress,
        address seller
    ) external initializer {
        __option_init(optn, seller);
        _priceFeed = AggregatorV3Interface(oracle);
        _baseCurrency = IERC20(baseCurrency);
        _token = IERC20(tokenAddress);
    }

    function escrowFunds(uint256 funds) external override onlySeller {
        require(funds > 0, "Amount: amount should be > 0");
        deposit(msg.sender, address(this), funds, _baseCurrency);
        emit Escrow(address(this), funds);
    }

    function terminateContract() external override onlySeller onlyNullBuyer {
        uint256 contractBalance = _baseCurrency.balanceOf(address(this));
        require(contractBalance > 0, "Balance: zero balance in contract");
        withdraw(seller, contractBalance, _baseCurrency);
        emit Terminate(address(this));
    }

    function payPremium() external override onlyNullBuyer {
        deposit(msg.sender, seller, optn.premium, _baseCurrency);
        setBuyer();
        initializeBlock();
        emit Premium(address(this));
    }

    function expireContract() external override onlySeller {
        require(optn.durationInBlock < block.number - initializationBlock);
        uint256 contractBalance = _baseCurrency.balanceOf(address(this));
        require(contractBalance > 0, "Balance: zero balance in contract");
        withdraw(seller, contractBalance, _baseCurrency);
        emit Expire(address(this));
    }

    function executeOption() external override onlyBuyer {
        int currentPrice = getLatestPrice(_priceFeed);

        require(currentPrice > 0, "price lesser than zerp");        
        require(currentPrice > optn.strikePrice, "current price lesser than strike price");

        uint256 contractBalance = _token.balanceOf(address(this));
        uint256 tokenCount = optn.amount / uint(optn.strikePrice);
        deposit(buyer, seller, tokenCount, IERC20(_token));
        withdraw(buyer, contractBalance, _baseCurrency);
        emit Execute(address(0));
    }
}
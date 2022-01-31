//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Option.sol";
import "./interface/ISellOption.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract SellCallOpttion is ISellOption, Option {

    IERC20 internal usd; 
    AggregatorV3Interface internal priceFeed;

    constructor(Optn memory optn, address usdAddress, address oracle) Option(optn) {
        priceFeed = AggregatorV3Interface(oracle);
        usd = IERC20(usdAddress);
    }

    function escrowFunds(uint256 funds) external override onlySeller {
        require(funds > 0, "Amount: amount should be > 0");
        deposit(msg.sender, address(this), funds, usd);
    }

    function terminateContract() external override onlySeller onlyNullBuyer {
        uint256 contractBalance = usd.balanceOf(address(this));
        require(contractBalance > 0, "Balance: zero balance in contract");
        withdraw(seller, contractBalance, usd);
    }

    function payPremium() external override onlyNullBuyer {
        deposit(msg.sender, seller, optn.premium, usd);
        setBuyer();
        initializeBlock();
    }

    function expireContract() external override onlySeller {
        require(optn.durationInBlock < block.number - initializationBlock);
        uint256 contractBalance = usd.balanceOf(address(this));
        require(contractBalance > 0, "Balance: zero balance in contract");
        withdraw(seller, contractBalance, usd);
    }

    function executeOption() external override onlyBuyer {
        int currentPrice = _getLatestPrice();
        require(currentPrice > 0, "price lesser than zerp");
        
        //put option
        require(currentPrice > optn.strikePrice, "current price lesser than strike price");

        uint256 contractBalance = optn.token.balanceOf(address(this));
        uint256 tokenCount = optn.amount / uint(optn.strikePrice);

        deposit(buyer, seller, tokenCount, IERC20(optn.token));
        withdraw(buyer, contractBalance, usd);
    }

    function _getLatestPrice() private view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
}
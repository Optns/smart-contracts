//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./../Optn.sol";
import "./SellPutOptionOrder.sol";
import "./SellCallOptionOrder.sol";
import "./interface/ISellOptionFactory.sol";

contract SellOptionFactory is ISellOptionFactory, Initializable {
    OrderBookStandard private _orderBookStandard;
    AggregatorV3Interface private _priceFeed;

    event SellPutOption(address sellPutOptionAddress, address selller);

    event SellCallOption(
        address sellCallOptionAddress,
        address indexed selller
    );

    function __sellOptionFactory_init(
        OrderBookStandard memory orderBookStandard
    ) external override initializer {
        _orderBookStandard = orderBookStandard;
        _priceFeed = AggregatorV3Interface(_orderBookStandard.oracle);
    }

    function getToken() external view override returns (IERC20) {
        return IERC20(_orderBookStandard.token);
    }

    function getBaseCurrency() external view override returns (IERC20) {
        return IERC20(_orderBookStandard.baseCurrency);
    }

    function getAmount() external view override returns (uint256) {
        return _orderBookStandard.amount;
    }

    function getDurationInBlock() external view override returns (uint256) {
        return _orderBookStandard.durationInBlock;
    }

    function latestPrice() external view override returns (int256) {
        (, int256 price, , , ) = _priceFeed.latestRoundData();
        return price;
    }

    function cloneSellPutContract(Optn memory optn, address seller)
        external
        override
        returns (bool)
    {
        address sellPutOptionAddress = ClonesUpgradeable.clone(
            _orderBookStandard.sellPutImp
        );
        ISellOptionOrder sellPutOption = ISellOptionOrder(sellPutOptionAddress);
        sellPutOption.__sellOption_init(optn, seller, address(this));
        emit SellPutOption(address(this), seller);
        return true;
    }

    function cloneCallPutContract(Optn memory optn, address seller)
        external
        override
        returns (bool)
    {
        address sellCallOptionAddress = ClonesUpgradeable.clone(
            _orderBookStandard.sellCallImp
        );
        ISellOptionOrder sellCallOption = ISellOptionOrder(
            sellCallOptionAddress
        );
        sellCallOption.__sellOption_init(optn, seller, address(this));
        emit SellCallOption(address(this), seller);
        return true;
    }
}

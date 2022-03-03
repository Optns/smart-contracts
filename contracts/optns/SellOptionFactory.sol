//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol';
import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import './struct/Optn.sol';
import './SellPutOptionOrder.sol';
import './SellCallOptionOrder.sol';
import './interface/ISellOptionFactory.sol';

contract SellOptionFactory is ISellOptionFactory, Initializable {
    OrderBookStandard private _orderBookStandard;

    event SellPutOption(address sellPutOptionAddress, address selller);

    event SellCallOption(address sellCallOptionAddress, address indexed selller);

    function __sellOptionFactory_init(OrderBookStandard memory orderBookStandard) external override initializer {
        _orderBookStandard = orderBookStandard;
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

    function getOrderBookStandard() external view override returns (OrderBookStandard memory) {
        return _orderBookStandard;
    }

    function cloneSellPutContract(Optn memory optn, address seller) external override {
        address sellPutOptionAddress = ClonesUpgradeable.clone(_orderBookStandard.sellPutImp);
        ISellOptionOrder sellPutOption = ISellOptionOrder(sellPutOptionAddress);
        sellPutOption.__sellOption_init(optn, seller, address(this));
        emit SellPutOption(address(this), seller);
    }

    function cloneSellCallContract(Optn memory optn, address seller) external override {
        address sellCallOptionAddress = ClonesUpgradeable.clone(_orderBookStandard.sellCallImp);
        ISellOptionOrder sellCallOption = ISellOptionOrder(sellCallOptionAddress);
        sellCallOption.__sellOption_init(optn, seller, address(this));
        emit SellCallOption(address(this), seller);
    }
}

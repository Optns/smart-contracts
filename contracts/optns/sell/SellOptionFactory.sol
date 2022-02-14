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

    address private _sellPutImp;
    address private _sellCallImp;
    address private _baseCurrency;
    address private _token;
    AggregatorV3Interface private _priceFeed;

    // list of contracts
    address[] private putOrders;
    address[] private callOrders;

    function __sellOptionFactory_init(OrderBookStandard memory orderBookStandard) override external initializer {
        _priceFeed = AggregatorV3Interface(orderBookStandard.oracle);
        _sellPutImp = orderBookStandard.sellPutImp;
        _sellCallImp = orderBookStandard.sellCallImp;
        _baseCurrency = orderBookStandard.baseCurrency;
        _token = orderBookStandard.token;
    }

    function getToken() external override view returns(IERC20){
        return IERC20(_token);
    }

    function getBaseCurrency() external override view returns(IERC20){ 
        return IERC20(_baseCurrency);
    }

    function latestPrice() override external view returns (int) {
        (
            , 
            int price,
            ,
            ,
        ) = _priceFeed.latestRoundData();
        return price;
    }

    function cloneSellPutContract(Optn memory optn, address seller) external override returns(bool){
        address sellPutOptionAddress = ClonesUpgradeable.clone(_sellPutImp);
        ISellOptionOrder sellPutOption = ISellOptionOrder(sellPutOptionAddress);
        sellPutOption.__sellOption_init(optn, seller, address(this));
        putOrders.push(sellPutOptionAddress);
        return true;
    }

    function cloneCallPutContract(Optn memory optn, address seller) external override returns(bool){
        address sellCallOptionAddress = ClonesUpgradeable.clone(_sellCallImp);
        ISellOptionOrder sellCallOption = ISellOptionOrder(sellCallOptionAddress);
        sellCallOption.__sellOption_init(optn, seller, address(this));
        callOrders.push(sellCallOptionAddress);
        return true;
    }
}
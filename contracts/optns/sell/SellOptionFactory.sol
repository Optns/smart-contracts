//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "./../Optn.sol";
import "./SellPutOptionOrder.sol";
import "./SellCallOptionOrder.sol";
import "./interface/ISellOptionFactory.sol";

contract SellOptionFactory is ISellOptionFactory, Initializable {

    address private _sellPutImp;
    address private _sellCallImp;
    address private _baseCurrency;
    address private _oracle;
    address private _token;

    mapping(address => address) private putOrders;
    mapping(address => address) private callOrders;

    function __sellOptionFactory_init(address baseCurrency, address oracle, address token)
        external
        initializer {
        _baseCurrency = baseCurrency; 
        _oracle = oracle;
        _token = token;
    }

    function setSellPutImp(address imp) external {
        require(_sellPutImp == address(0), "Implementation already defined");
        _sellPutImp = imp;
    }

    function setSellCallImp(address imp) external {
        require(_sellCallImp == address(0), "Implementation already defined");
        _sellCallImp = imp;
    }

    function cloneSellPutContract(Optn memory optn, address seller) external {
        address sellPutOptionAddress = ClonesUpgradeable.clone(_sellPutImp);
        ISellOptionOrder sellPutOption = ISellOptionOrder(sellPutOptionAddress);
        sellPutOption.__sellOption_init(optn, _baseCurrency, _oracle, _token, seller);
        putOrders[sellPutOptionAddress] = msg.sender;
    }

    function cloneCallPutContract(Optn memory optn, address seller) external {
        address sellCallOptionAddress = ClonesUpgradeable.clone(_sellCallImp);
        ISellOptionOrder sellCallOption = ISellOptionOrder(sellCallOptionAddress);
        sellCallOption.__sellOption_init(optn, _baseCurrency, _oracle, _token, seller);
        callOrders[sellCallOptionAddress] = msg.sender;
    }
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import './interface/IOptionFactory.sol';
import './struct/Optn.sol';

contract OrderBookFactory is Initializable {
    address private _optionFactory;

    function __orderBookFactory_init(address optionFactory) external initializer {
        _optionFactory = optionFactory;
    }

    event OrderBookCreated(address orderBookAddress, address indexed token, address indexed baseCurrency);

    function createMarket(OrderBookStandard memory orderBookStandard) external {
        address orderBookAddress = ClonesUpgradeable.clone(_optionFactory);
        IOptionFactory optionFactory = IOptionFactory(orderBookAddress);
        optionFactory.__optionFactory_init(orderBookStandard);
        emit OrderBookCreated(orderBookAddress, orderBookStandard.token, orderBookStandard.baseCurrency);
    }
}

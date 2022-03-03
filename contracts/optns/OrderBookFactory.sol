//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./interface/ISellOptionFactory.sol";
import "./struct/Optn.sol";

contract OrderBookFactory is Initializable {
    address private _sellOptionFactory;

    function __orderBookFactory_init(address sellOptionFactory)
        external
        initializer
    {
        _sellOptionFactory = sellOptionFactory;
    }

    event OrderBookCreated(
        address orderBookAddress,
        address indexed token,
        address indexed baseCurrency
    );

    function createMarket(OrderBookStandard memory orderBookStandard) external {
        address orderBookAddress = ClonesUpgradeable.clone(_sellOptionFactory);
        ISellOptionFactory sellOptionFactory = ISellOptionFactory(
            orderBookAddress
        );
        sellOptionFactory.__sellOptionFactory_init(orderBookStandard);
        emit OrderBookCreated(
            orderBookAddress,
            orderBookStandard.token,
            orderBookStandard.baseCurrency
        );
    }
}

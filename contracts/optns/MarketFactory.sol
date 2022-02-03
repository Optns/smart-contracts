//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "./sell/interface/ISellOptionFactory.sol";

contract MarketFactory {

    mapping(address => address) private markets;

    event MarketCreated(address marketAddress, address token, address oracle, address baseCurrency);

    function createMarket(
        address sellOptionFactoryAddress,
        address baseCurrency,
        address oracle,
        address token
    ) external {
        address marketAddress = ClonesUpgradeable.clone(sellOptionFactoryAddress);
        ISellOptionFactory sellOptionFactory = ISellOptionFactory(marketAddress);
        sellOptionFactory.__sellOptionFactory_init(baseCurrency, oracle, token);
        markets[marketAddress] = token;
        emit MarketCreated(marketAddress, token, oracle, baseCurrency);
    }
}
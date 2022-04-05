//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import './interface/IOrderBookfactory.sol';
import './interface/IOptionFactory.sol';
import './lib/SharedStructs.sol';

contract OrderBookFactory is IOrderBookFactory, Initializable {
    
    address private _optionFactory;
    address private _gov;

    modifier onlyGov {
        require(msg.sender == _gov);
        _;
    }

    mapping(bytes32 => address) private _markets;

    function __orderBookFactory_init(address optionFactory) external override initializer {
        _optionFactory = optionFactory;
        _gov = msg.sender;
    }

    function getGov() external view override returns(address gov) {
        gov = _gov;
    }

    function getOptionFactory() external view override returns(address optionFactory) {
        optionFactory = _optionFactory;
    }

    function getMarketAddress(bytes32 pairHash) external view override returns(address marketAddress) {
        marketAddress = _markets[pairHash];
    }

    function changeGov(address gov) external override onlyGov{
        _gov = gov;
    }

    function changeOptionFactory(address optionFactoryAddress) external override onlyGov {
        _optionFactory = optionFactoryAddress;
    }

    function updateOrderBookStandard(
        SharedStructs.OrderbookStandard memory orderbookStandard,
        address orderbookAddress) external override onlyGov {
        IOptionFactory optionFactory = IOptionFactory(orderbookAddress);
        optionFactory.updateOrderBookStandard(orderbookStandard);
    }

    function createMarket(
        SharedStructs.OrderbookStandard memory orderbookStandard) external override onlyGov {
        bytes32 marketHash = _createTokenPairHash(orderbookStandard.tokenIn, orderbookStandard.tokenOut);
        require(_validMarket(marketHash));
        require(_powAmountValid(orderbookStandard.amountPow));

        address orderBookAddress = _createClone(orderbookStandard);
        _markets[marketHash] = orderBookAddress;
    }

    function _createClone(SharedStructs.OrderbookStandard memory orderbookStandard) private returns(address orderBookAddress){
        orderBookAddress = ClonesUpgradeable.clone(_optionFactory);
        IOptionFactory optionFactory = IOptionFactory(orderBookAddress);
        optionFactory.__optionFactory_init();
        optionFactory.updateOrderBookStandard(orderbookStandard);
    }

    function _createTokenPairHash(address tokenIn, address tokenOut) private pure returns(bytes32 tokenPairHash) {
        tokenPairHash = keccak256(abi.encodePacked(tokenIn, tokenOut));
    }

    function _validMarket(bytes32 tokenPairHash) private view returns(bool){
        return _markets[tokenPairHash] == address(0);
    }

    function _powAmountValid(uint amountPow) private pure returns(bool){
        require(amountPow < 32);
        return true;
    }
}

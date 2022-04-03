//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol';
import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import './interface/IOptionFactory.sol';
import './interface/IOption.sol';
import './lib/SharedStructs.sol';

contract OptionFactory is IOptionFactory, Initializable {

    address private _owner;
    SharedStructs.OrderbookStandard private _orderbookStandard;

    event OptionEvent(address optionAddress, address selller);

    modifier onlyAdmin {
        require(msg.sender == _owner);
        _;
    }

    function __optionFactory_init() external override initializer {
        _owner = msg.sender;
    }

    function updateOrderBookStandard(SharedStructs.OrderbookStandard memory orderBookStandard) external onlyAdmin {
        _orderbookStandard = orderBookStandard;
    }

    function updateOwner(address owner) external override {
        _owner = owner;
    }

    function cloneOptionContract(SharedStructs.Option memory option) external override {
        address optionAddress = ClonesUpgradeable.clone(_orderbookStandard.implementation);
        IOption optionContract = IOption(optionAddress);

        SharedStructs.OptionStandard memory optionStandard;
        optionStandard.tokenIn = _orderbookStandard.token1;
        optionStandard.tokenOut = _orderbookStandard.token2;
        optionStandard.amount = 10 ** (18 + _orderbookStandard.amountPow);

        optionContract.__option_init(option, msg.sender, optionStandard);
        emit OptionEvent(optionAddress, msg.sender);
    }
}

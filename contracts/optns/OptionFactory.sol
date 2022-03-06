//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol';
import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import './struct/Optn.sol';
import './interface/IOptionFactory.sol';
import './interface/IOption.sol';

contract OptionFactory is IOptionFactory, Initializable {
    OrderBookStandard private _orderBookStandard;

    event Option(address optionAddress, address selller, OptionType optionType);

    function __optionFactory_init(OrderBookStandard memory orderBookStandard) external override initializer {
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

    function cloneOptionContract(Optn memory optn, address seller, OptionType optionType) external override {
        address optionAddress = ClonesUpgradeable.clone(_orderBookStandard.implementation);
        IOption option = IOption(optionAddress);
        option.__option_init(optn, seller, address(this), optionType);
        emit Option(optionAddress, seller, optionType);
    }
}

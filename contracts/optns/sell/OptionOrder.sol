//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interface/IOptionOrder.sol";
import "./../Optn.sol";

/**
 * @dev Implementation of the { IOptn } interface.
 */
abstract contract OptionOrder is IOptionOrder {
    Optn internal optn;
    uint256 internal initializationBlock;
    address internal seller;
    address internal buyer;

    function __option_init(Optn memory _optn, address _seller) internal {
        seller = _seller;
        optn = _optn;
        initializationBlock = 0;
    }

    event Escrow(address order, uint256 amount);
    event Terminate(address order);
    event Premium(address order);
    event Expire(address order);
    event Execute(address order);

    modifier onlySeller() {
        require(seller == msg.sender, "Access: caller is not seller");
        _;
    }

    modifier onlyBuyer() {
        require(buyer == msg.sender, "Access: caller is not buyer");
        _;
    }

    modifier onlyNullBuyer() {
        require(buyer == address(0), "Access: buyer found");
        _;
    }

    function getSeller() internal view returns (address) {
        return seller;
    }

    function getBuyer() internal view returns (address) {
        return buyer;
    }

    function setBuyer() internal {
        buyer = msg.sender;
    }

    function order() external view override returns (Order memory) {
        return Order(optn, seller, buyer, initializationBlock);
    }

    function viewInitializationBlock()
        external
        view
        override
        returns (uint256)
    {
        return initializationBlock;
    }

    function getOptn() internal view returns (Optn memory) {
        return optn;
    }

    function initializeBlock() internal {
        require(initializationBlock == 0);
        initializationBlock = block.number;
    }

    function withdraw(
        address to,
        uint256 amount,
        IERC20 token
    ) internal {
        token.transfer(to, amount);
    }

    function deposit(
        address from,
        address to,
        uint256 amount,
        IERC20 token
    ) internal {
        _allownace(from, amount, token);
        token.transferFrom(from, to, amount);
    }

    function _allownace(
        address from,
        uint256 amount,
        IERC20 token
    ) private view {
        uint256 allowance = token.allowance(from, address(this));
        require(allowance >= amount, "Permission: Allowance != amount");
    }
}

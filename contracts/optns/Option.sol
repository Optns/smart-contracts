//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './interface/IOption.sol';
import './struct/Optn.sol';
import './interface/IOptionFactory.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

/**
 * @dev Implementation of the { IOptn } interface.
 */
 
contract Option is IOption, Initializable {
    Optn private _optn;
    uint256 private _initializationBlock;
    address private _seller;
    address private _buyer;
    IOptionFactory private _orderbook;
    OptionType _optionType;
    Status _status;

    function __option_init(Optn memory optn, address seller, address orderbook, OptionType optionType) external override initializer {
        _seller = seller;
        _optn = optn;
        _initializationBlock = 0;
        _orderbook = IOptionFactory(orderbook);
        _optionType = optionType;
        _status = Status.INIT;
    }

    modifier onlySeller() {
        require(_seller == msg.sender, 'Access: caller is not seller');
        _;
    }

    modifier onlyBuyer() {
        require(_buyer == msg.sender, 'Access: caller is not buyer');
        _;
    }

    modifier onlyNullBuyer() {
        require(_buyer == address(0), 'Access: buyer found');
        _;
    }

    modifier onlyInit() {
        require(_status == Status.INIT, "Status not INIT");
        _;
    }

    modifier onlyEscrowed() {
        require(_status == Status.ESCROWED, "Status not ESCROWED");
        _;
    }

    modifier onlyBought() {
        require(_status == Status.BOUGHT, "Status not BOUGHT");
        _;
    }

    modifier onlyExpired() {
        uint256 durationInBlock = _orderbook.getDurationInBlock();
        require(durationInBlock < block.number - _initializationBlock, "Not expired");
        _;
    }

    function getSeller() external view override returns (address) {
        return _seller;
    }

    function getBuyer() external view override returns (address) {
        return _buyer;
    }

    function getOrder() external view override returns (Optn memory) {
        return _optn;
    }

    function getInitializationBlock() external view override returns(uint256) {
        return _initializationBlock;
    }

    function getStatus() external view override returns(Status) {
        return _status;
    }

    function escrow() external override onlySeller onlyInit {
        uint256 amount = _orderbook.getAmount();
        require(amount > 0, 'Amount: amount should be > 0');

        IERC20 escrowToken =_getEscrowToken();
        
        bool response = _deposit(msg.sender, address(this), amount, escrowToken);
        require(response == true, "deposit failed");
        _status = Status.ESCROWED;
    }

    function cancel() external override onlySeller onlyNullBuyer onlyEscrowed {
        IERC20 escrowToken = _getEscrowToken();

        uint256 contractBalance = escrowToken.balanceOf(address(this));
        require(contractBalance > 0, 'Balance: zero balance in contract');

        bool response = _withdraw(_seller, contractBalance, escrowToken);
        require(response == true, "withdraw failed");
        _status = Status.CLOSED;
    }

    function buy() external override onlyNullBuyer onlyEscrowed {
        IERC20 baseCurrency = _orderbook.getBaseCurrency();

        bool response = _deposit(msg.sender, _seller, _optn.premium, baseCurrency);
        require(response == true, "deposit failed");
        _setBuyer();
    }

    function expire() external override onlyBought onlyExpired {
        IERC20 escrowToken = _getEscrowToken();

        uint256 contractBalance = escrowToken.balanceOf(address(this));
        require(contractBalance > 0, 'Balance: zero balance in contract');

        bool response = _withdraw(_seller, contractBalance, escrowToken);
        require(response == true, "withdraw failed");
        _status = Status.CLOSED;
    }

    function execute() external override onlyBuyer onlyBought {
        
    }

    function _setBuyer() private {
        _initializationBlock = block.number;
        _buyer = msg.sender;
        _status = Status.BOUGHT;
    }

    function _getEscrowToken() private view returns(IERC20 escrowToken) {
        if(_optionType == OptionType.PUT ) {
            return _orderbook.getToken();
        } else if (_optionType == OptionType.CALL) {
            return _orderbook.getBaseCurrency();
        }
    }

    function _withdraw(
        address to,
        uint256 amount,
        IERC20 token
    ) private returns(bool) {
        bool response = token.transfer(to, amount);
        require(response == true, "transfer failed");
        return true;
    }

    function _deposit(
        address from,
        address to,
        uint256 amount,
        IERC20 token
    ) private returns(bool) {
        _allownace(from, amount, token);
        bool response = token.transferFrom(from, to, amount);
        require(response == true, "transfer from faield");
        return true;
    }

    function _allownace(
        address from,
        uint256 amount,
        IERC20 token
    ) private view {
        uint256 allowance = token.allowance(from, address(this));
        require(allowance >= amount, 'Permission: Allowance != amount');
    }
}

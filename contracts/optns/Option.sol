//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './interface/IERC20.sol';
import './interface/IOption.sol';
import './interface/IOptionFactory.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import './lib/SharedStructs.sol';

/**
 * @dev Implementation of the { IOptn } interface.
 */
 
contract Option is IOption, Initializable {
    
    struct Participants {
        address seller;
        address buyer;
    }

    SharedStructs.Option private _option;
    SharedStructs.OptionStandard private _optionStandard;
    uint256 private _expiryTimestamp;
    Participants private _participants;
    Status private _status;
    
    ISwapRouter public constant swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    uint24 public constant poolFee = 3000;

    function __option_init(SharedStructs.Option memory option, address seller, SharedStructs.OptionStandard memory optionStandard) external override initializer {
        _participants.seller = seller;
        _option = option;
        _optionStandard = optionStandard;
        _status = Status.INIT;
    }

    modifier onlySeller() {
        require(_participants.seller == msg.sender, 'Access: caller is not seller');
        _;
    }

    modifier onlyBuyer() {
        require(_participants.buyer == msg.sender, 'Access: caller is not buyer');
        _;
    }

    modifier onlyNullBuyer() {
        require(_participants.buyer == address(0), 'Access: buyer found');
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
        require(block.timestamp > _expiryTimestamp, "Not expired");
        _;
    }

    function getSeller() external view override returns (address seller) {
        seller = _participants.seller;
    }

    function getBuyer() external view override returns (address buyer) {
        buyer = _participants.buyer;
    }

    function getOrder() external view override returns (SharedStructs.Option memory option) {
        option = _option;
    }

    function getOptionStandard() external view override returns (SharedStructs.OptionStandard memory optionStandard) {
        optionStandard = _optionStandard;
    }

    function getExpiryTimestamp() external view override returns(uint256 expiry) {
        expiry = _expiryTimestamp;
    }

    function getStatus() external view override returns(Status) {
        return _status;
    }

    function escrow() external override onlySeller onlyInit {
        require(_optionStandard.amount > 0, 'Amount: amount should be > 0');        
        bool response = _deposit(msg.sender, address(this), _optionStandard.amount, _optionStandard.tokenIn);
        require(response == true, "deposit failed");
        _status = Status.ESCROWED;
    }

     function cancel() external override onlySeller onlyNullBuyer onlyEscrowed {
        uint256 contractBalance = IERC20(_optionStandard.tokenIn).balanceOf(address(this));
        require(contractBalance > 0, 'Balance: zero balance in contract');

        bool response = _withdraw(_participants.seller, contractBalance, _optionStandard.tokenIn);
        require(response == true, "withdraw failed");
        _status = Status.CLOSED;
    }

    function buy() external override onlyNullBuyer onlyEscrowed {

        bool response = _deposit(msg.sender, _participants.seller, _option.premium, _optionStandard.tokenOut);
        require(response == true, "deposit failed");
        _setBuyer();
    }

    function expire() external override onlyBought onlyExpired {
        uint256 contractBalance = IERC20(_optionStandard.tokenIn).balanceOf(address(this));
        require(contractBalance > 0, 'Balance: zero balance in contract');

        bool response = _withdraw(_participants.seller, contractBalance, _optionStandard.tokenIn);
        require(response == true, "withdraw failed");
        _status = Status.CLOSED;
    }

    function execute() external override onlyBuyer onlyBought {
        uint256 contractBalance = IERC20(_optionStandard.tokenIn).balanceOf(address(this));
        require(contractBalance > 0, 'Balance: zero balance in contract');

        uint256 minAmountOut = _getMinAmountOut(_option.strikePrice, contractBalance);
        uint256 amountOut = _swap(_optionStandard.tokenIn, _optionStandard.tokenOut, _option.strikePrice, contractBalance, poolFee);
        require(amountOut >= minAmountOut, 'swap failed');
        _status = Status.CLOSED;
    }

    function _setBuyer() private {
        _expiryTimestamp = _calExpiryTimestamp(_option.duration);
        _participants.buyer = msg.sender;
        _status = Status.BOUGHT;
    }

    function _swap(address tokenIn, address tokenOut, uint256 contractBalance, uint256 minAmountOut, uint24 fee) private returns(uint256 amountOut) {
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: fee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: contractBalance,
                amountOutMinimum: minAmountOut,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);
    }

    function _withdraw(
        address to,
        uint256 amount,
        address token
    ) private returns(bool) {
        bool response = IERC20(token).transfer(to, amount);
        require(response == true, "transfer failed");
        return true;
    }

    function _deposit(
        address from,
        address to,
        uint256 amount,
        address token
    ) private returns(bool) {
        _allownace(from, amount, token);
        bool response = IERC20(token).transferFrom(from, to, amount);
        require(response == true, "transfer from faield");
        return true;
    }

    function _allownace(
        address from,
        uint256 amount,
        address token
    ) private view {
        uint256 allowance = IERC20(token).allowance(from, address(this));
        require(allowance >= amount, 'Permission: Allowance != amount');
    }

    function _getMinAmountOut(uint256 strikePrice, uint256 amount) private pure returns(uint256 minAmountOut) {
        minAmountOut = amount * strikePrice;
    }

    function _calExpiryTimestamp(SharedStructs.Duration duration) private view returns(uint256) {
        if (duration == SharedStructs.Duration.DAY) {
            return block.timestamp + 3600;
        } else if (duration == SharedStructs.Duration.WEEK) {
            return block.timestamp + 86400;
        } else if (duration == SharedStructs.Duration.MONTH) {
            return block.timestamp + 2629746;
        } else if (duration == SharedStructs.Duration.YEAR) {
            return block.timestamp + 31556952;
        }
        return block.timestamp + 3600;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Access {
    address _seller;
    address _buyer;
    
    constructor() {
        _seller = msg.sender;
    }

    modifier onlySeller() {
        require(_seller == msg.sender, "Access: caller is not seller");
        _;
    }

    modifier onlyBuyer() {
        require(_buyer == msg.sender, "Access: caller is not buyer");
        _;
    }

    modifier onlyNullBuyer() {
        require(_buyer == address(0), "Access: buyer found");
        _;
    }

    function seller() external view returns(address) {
        return _seller;
    }

    function buyer() external view returns(address) {
        return _buyer;
    }

    function setBuyer() internal {
        _buyer = msg.sender;
    }

}
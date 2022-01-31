//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Access {
    address internal seller;
    address internal buyer;
    
    constructor() {
        seller = msg.sender;
    }

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

    function getSeller() external view returns(address) {
        return seller;
    }

    function getBuyer() external view returns(address) {
        return buyer;
    }

    function setBuyer() internal {
        buyer = msg.sender;
    }

}
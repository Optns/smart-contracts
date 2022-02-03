//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./../../Optn.sol";

interface ISellOptionFactory {
    function __sellOptionFactory_init(address usdAddress, address oracle, address token) external;

    function setSellPutImp(address imp) external;
    
    function setSellCallImp(address imp) external;

    function cloneSellPutContract(Optn memory optn, address seller) external;

    function cloneCallPutContract(Optn memory optn, address seller) external;
}
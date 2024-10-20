// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IManagementPolicy } from "../interfaces/IManagementPolicy.sol";


contract StoryPolicy is IManagementPolicy {

    constructor() {

    }

    function numberAllowedTokens(uint256) public pure returns (uint256){
        return 0;
    }
    function getAllowedTokenAddress(uint256 , uint256) public pure returns (address) {
        return address(0);
    }
    function getAllowedOracleAddress(uint256, uint256) public pure returns (address) {
        return address(0);
    }

    function isContractAllowed(uint32 _chainEid, address) public pure returns (bool){
        if(_chainEid == 40315){
            return true;
        }
        return false;
    }

}
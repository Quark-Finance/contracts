// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IManagementPolicy } from "../interfaces/IManagementPolicy.sol";


contract HyperdrivePolicy is IManagementPolicy {

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

    function isContractAllowed(uint32 _chainEid, address _target) public pure returns (bool){
        address targetDai = 0xe8b99bF4249D90C0eB900651F92485F7160A0513;

        address hyperdrive = 0x8eA2c57C107682C50D77cd4D5517F8Dcf5E2EdE8;
        if(_chainEid == 40161 && (_target == targetDai || _target ==hyperdrive)){
            return true;
        }
        return false;
    }

}
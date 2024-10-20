// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IChronicle } from "../interfaces/IChronicle.sol";


contract MockChronicleDataFeed is IChronicle {

    uint256 public value;

    constructor(uint256 _value) {
        value = _value;
    }

    function read() external view returns (uint256) {
        return value;
    }

}
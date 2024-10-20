// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IDepositPolicy {

    function validDepositor(address _depositor) external view returns (bool);

}
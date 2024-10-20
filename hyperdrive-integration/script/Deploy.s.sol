// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {  HyperDriveIntegration } from "../src/HyperDriveIntegration.sol";
import {IHyperdrive} from "hyperdrive/contracts/src/interfaces/IHyperdrive.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CounterScript is Script {

    HyperDriveIntegration hyperdrive;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        hyperdrive = new HyperDriveIntegration(IHyperdrive(0xD5D9556052dB810Da774BeC127cd2aFF548a6571)); // base market

        

        

        vm.stopBroadcast();
    }
}

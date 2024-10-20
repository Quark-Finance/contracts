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

        hyperdrive = new HyperDriveIntegration(IHyperdrive(0xfA8dB2177F1e1eE4327c9b9d1389b1173bC5A5e2)); // sepolia market

        IERC20(0xe8b99bF4249D90C0eB900651F92485F7160A0513).approve(address(hyperdrive), 10e18);


        hyperdrive.openLongHyperDrive(10e18);

        console.log("Hyperdrive: ", address(hyperdrive));
        

        vm.stopBroadcast();
    }
}

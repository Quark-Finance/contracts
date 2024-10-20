// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import { IPARegistrar } from "../src/IPARegistrar.sol";




contract DeployIPARegistrar is Script {

    // For addresses, see https://docs.storyprotocol.xyz/docs/deployed-smart-contracts
    // Protocol Core - IPAssetRegistry
    address internal ipAssetRegistryAddr = 0x1a9d0d28a0422F26D31Be72Edc6f13ea4371E11B;
    // Protocol Periphery - RegistrationWorkflows
    address internal registrationWorkflowsAddr = 0x601C24bFA5Ae435162A5dC3cd166280C471d16c8;

    IPARegistrar public ipaRegistrar;
    

    function setUp() public {}

    function run() public {

        //uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast();

        ipaRegistrar = new IPARegistrar(ipAssetRegistryAddr, registrationWorkflowsAddr);

        ipaRegistrar.mintIp();

        vm.stopBroadcast();
        
    }
}
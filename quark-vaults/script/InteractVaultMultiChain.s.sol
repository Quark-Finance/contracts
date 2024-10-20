// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";


import { QuarkFactory } from "../contracts/QuarkFactory.sol";
import { QuarkHubChainAccount } from "../contracts/QuarkHubChainAccount.sol";

import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";




contract  CreateVaultAndSetSpokeChain is Script {

    using OptionsBuilder for bytes;

    uint128 GAS_LIMIT_SEND = 5000000;  //Gas limit for the executor
    uint128 MSG_VALUE_SEND = 10000000000000000; // msg.value for the lzReceive() function on destination in wei

    uint128 GAS_LIMIT_RETURN = 3000000;
    uint128 MSG_VALUE_RETURN = 0;


    QuarkFactory public factoryHubChain;

    function setUp() public {}

    function run() public {

        //uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast();


        uint256 vaultId = 0;

        address factoryHubChainAddress =   0x1647c455e79dbFF1fC6AE3BE08235F7F1f455E12;

        factoryHubChain = QuarkFactory(factoryHubChainAddress);

        address vaultAddress = factoryHubChain.quarkHubChainAccounts(vaultId);

        console.log("Vault Address: ", vaultAddress);


        QuarkHubChainAccount vault = QuarkHubChainAccount(payable(vaultAddress));


        uint256 spokeChainId = 	11155111;
        uint32 spokeChainEid = 40161;

        address targetDai = 0xe8b99bF4249D90C0eB900651F92485F7160A0513;

        address hyperDrive = 0x8eA2c57C107682C50D77cd4D5517F8Dcf5E2EdE8;

        //vault.executeOnSpokeChain{value: 195860172447595}(spokeChainEid, targetDai, abi.encodeWithSignature("mint(address,uint256)", address(vault.spokeChainsAccounts(spokeChainEid)), 999 ether));

        //vault.executeOnSpokeChain{value: 195860172447595}(spokeChainEid, targetDai, abi.encodeWithSignature("approve(address,uint256)", address(hyperDrive), 100 ether));

        vault.executeOnSpokeChain{value: 195860172447595}(spokeChainEid, hyperDrive, abi.encodeWithSignature("openLongHyperDrive(uint256)", 10 ether));
        vm.stopBroadcast();
        
    }
}
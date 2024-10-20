// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";


import { QuarkFactory } from "../contracts/QuarkFactory.sol";
import { QuarkHubChainAccount } from "../contracts/QuarkHubChainAccount.sol";

import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";




contract  CreateSpokeChainEmergency is Script {

    using OptionsBuilder for bytes;


    QuarkFactory public factoryHubChain;

    function setUp() public {}

    function run() public {

        //uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast();

        address factoryHubChainAddress =   0x9F0a79c5A1Fb5f7E2221Ddda85362f97FF847F66;

        factoryHubChain = QuarkFactory(factoryHubChainAddress);

        uint256 vaultId = 0;
        address _newSpoke = 0x9F0a79c5A1Fb5f7E2221Ddda85362f97FF847F66;
        uint32 _srcEid = 1;

        factoryHubChain.registerSpokeChainEmergency(vaultId, _srcEid, _newSpoke);

        vm.stopBroadcast();
        
    }
}
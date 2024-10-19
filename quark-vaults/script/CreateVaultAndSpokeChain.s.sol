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

        address factoryHubChainAddress =  0xc9A98C1697B7F46d2074bf8aFEE41F516cAbDCd0;

        factoryHubChain = QuarkFactory(factoryHubChainAddress);

        uint256 vaultId = factoryHubChain.createVault();

        //uint256 vaultId = 0;

        QuarkHubChainAccount vault = QuarkHubChainAccount(payable(factoryHubChain.quarkHubChainAccounts(vaultId)));


        uint256 spokeChainId = 	11155420;

        //factoryHubChain.createSpokeChainAccount{ value: 100000000000000000 }(vaultId, spokeChainId);


        vault.requestNewSpokeChain{ value: 100000000000000000 }(vaultId, spokeChainId);
        vm.stopBroadcast();
        
    }
}
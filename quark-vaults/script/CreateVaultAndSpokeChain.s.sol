// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";


import { QuarkFactory } from "../contracts/QuarkFactory.sol";
import { VaultHubChainAccount } from "../contracts/VaultHubChainAccount.sol";

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

        address factoryHubChainAddress =0xA6a8D2E88ce6aCD7b14E99f8738902a5e948Af43;


        factoryHubChain = QuarkFactory(factoryHubChainAddress);

        //uint256 vaultId = factoryHubChain.createVault();

        //uint256 vaultId = 0;

        //VaultHubChainAccount vault = VaultHubChainAccount(payable(factoryHubChain.vaultHubChainAccounts(vaultId)));


        uint256 spokeChainId = 84532;

        // bytes memory _optionsSend = OptionsBuilder.newOptions().addExecutorLzReceiveOption(GAS_LIMIT_SEND, MSG_VALUE_SEND);
        // bytes memory _optionsReturn = OptionsBuilder.newOptions().addExecutorLzReceiveOption(GAS_LIMIT_RETURN, MSG_VALUE_RETURN);

        bytes memory _extraSendOptions = OptionsBuilder.newOptions().addExecutorLzReceiveOption(1000000, uint128(10000000000000000)); // gas settings for A -> B

        bytes memory _extraReturnOptions = OptionsBuilder.newOptions().addExecutorLzReceiveOption(1000000, uint128(10000000000000000)); // gas settings for B -> A




        // bytes memory a = hex"000301002101000000000000000000000000004c4b400000000000000000002386f26fc10000";
        // bytes memory b = hex"000301001101000000000000000000000000002dc6c0";

        factoryHubChain.createSpokeChainAccount{ value: 500000000000000000 }(0, spokeChainId, _extraSendOptions, _extraReturnOptions);


        //vault.requestNewSpokeChain{ value: 500000000000000000 }(vaultId, spokeChainId, _extraSendOptions, _extraReturnOptions);
        vm.stopBroadcast();
        
    }
}
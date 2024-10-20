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

        address factoryHubChainAddress =  0x5d48ad1c41b32caf687716f871C4e46687605924;

        factoryHubChain = QuarkFactory(factoryHubChainAddress);

        address vaultAddress = factoryHubChain.quarkHubChainAccounts(vaultId);

        console.log("Vault Address: ", vaultAddress);


        QuarkHubChainAccount vault = QuarkHubChainAccount(payable(0x9adC31B49cb51Ab47fA9A87918E5824d8C4E7134));


        uint256 spokeChainId = 	84532;
        uint32 spokeChainEid = 40245;

        address target = 0xbd856Ea0F5Acc0C1aF74B2b829c71940722850EF;

        vault.executeOnSpokeChain{value: 90700837514595}(spokeChainEid, target, abi.encodeWithSignature("mint(address,uint256)", address(vault.spokeChainsAccounts(spokeChainEid)), 10 ether));

        //vault.requestNewSpokeChain{ value: 13087962049559454 }(vaultId, spokeChainId);
        vm.stopBroadcast();
        
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";


import { QuarkFactory } from "../contracts/QuarkFactory.sol";



contract  SetupConfigHubChainFactoryRegistrySepoliaToLineaSepolia is Script {
    


    QuarkFactory public factoryHubChain;




    function setUp() public {}

    function run() public {

        //uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast();

        address factoryHubChainAddress =  0x9F0a79c5A1Fb5f7E2221Ddda85362f97FF847F66;
        uint32 spokeChainEid = 	 40161;
        address spokeChainRegistryAddresss = 0xc8db794088542F878a734c4f23E22b04F498B80F;

        uint256 spokeChainId = 11155111;


        factoryHubChain = QuarkFactory(factoryHubChainAddress);

        factoryHubChain.setSpokeChainConfig(spokeChainId, spokeChainRegistryAddresss, spokeChainEid);
        
        vm.stopBroadcast();
        
    }
}
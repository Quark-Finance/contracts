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

        address factoryHubChainAddress =  0x1647c455e79dbFF1fC6AE3BE08235F7F1f455E12;
        uint32 spokeChainEid = 	 40161;
        address spokeChainRegistryAddresss = 0xF4E68f7b7Acd54947F33e475497Bf487489fD14f;

        uint256 spokeChainId = 11155111;


        factoryHubChain = QuarkFactory(factoryHubChainAddress);

        factoryHubChain.setSpokeChainConfig(spokeChainId, spokeChainRegistryAddresss, spokeChainEid);
        
        vm.stopBroadcast();
        
    }
}
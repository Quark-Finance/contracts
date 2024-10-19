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

        address factoryHubChainAddress =  0xA6a8D2E88ce6aCD7b14E99f8738902a5e948Af43;
        uint32 spokeChainEid = 	40245;
        address spokeChainRegistryAddresss =   0xFFf10350Da68466F5abeCCdA400F9B79bB450CaF;

        uint256 spokeChainId = 84532;


        factoryHubChain = QuarkFactory(factoryHubChainAddress);

        factoryHubChain.setSpokeChainConfig(spokeChainId, spokeChainRegistryAddresss, spokeChainEid);
        
        vm.stopBroadcast();
        
    }
}
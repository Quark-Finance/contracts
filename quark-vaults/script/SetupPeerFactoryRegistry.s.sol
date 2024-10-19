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

        address factoryHubChainAddress =   0xc9A98C1697B7F46d2074bf8aFEE41F516cAbDCd0;
        uint32 spokeChainEid = 	40232;
        address spokeChainRegistryAddresss =    0x1C1e5A1db93dFE56dc52904c8cdCE66EEDaEc14D;

        uint256 spokeChainId = 11155420;


        factoryHubChain = QuarkFactory(factoryHubChainAddress);

        factoryHubChain.setSpokeChainConfig(spokeChainId, spokeChainRegistryAddresss, spokeChainEid);
        
        vm.stopBroadcast();
        
    }
}
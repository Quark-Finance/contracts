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

        address factoryHubChainAddress =  0x5d48ad1c41b32caf687716f871C4e46687605924;
        uint32 spokeChainEid = 	 40245;
        address spokeChainRegistryAddresss = 0xae133BED32fB31E182D900AB482B8fC0defDa25D;

        uint256 spokeChainId = 84532;


        factoryHubChain = QuarkFactory(factoryHubChainAddress);

        factoryHubChain.setSpokeChainConfig(spokeChainId, spokeChainRegistryAddresss, spokeChainEid);
        
        vm.stopBroadcast();
        
    }
}
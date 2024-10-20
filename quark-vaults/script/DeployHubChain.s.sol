// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";



import { QuarkHubChainAccount } from "../contracts/QuarkHubChainAccount.sol";
import { QuarkFactory } from "../contracts/QuarkFactory.sol";
import { MockERC20 } from "../contracts/mocks/MockERC20.sol";

import { RegistryHubChain } from "../contracts/RegistryHubChain.sol";


contract DeployHubChain is Script {
    
    QuarkFactory public factoryHubChain;
    MockERC20 public currencyHubChain;
    RegistryHubChain public registry;




    function setUp() public {}

    function run() public {

        //uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast();

        currencyHubChain = new MockERC20("USDC", "USDC");

        
        address owner = 0x000ef5F21dC574226A06C76AAE7060642A30eB74;
        address endpointHubChain = 0x6EDCE65403992e310A62460808c4b910D972f10f;

        registry = new RegistryHubChain(owner);

        

        factoryHubChain = new QuarkFactory(owner,  address(registry), address(currencyHubChain), endpointHubChain);

        console.log("-------- Hub Chain DEPLOYMENT --------");
        console.log("Chain Id: ", block.chainid);
        console.log("currency address: ", address(currencyHubChain));
        console.log("Owner address: ", owner);
        console.log("Endpoint Hub Chain address: ", endpointHubChain);
        console.log("Factory address: ", address(factoryHubChain));

        vm.stopBroadcast();
        
    }
}
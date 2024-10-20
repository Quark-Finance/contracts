// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";




import { MockERC20 } from "../contracts/mocks/MockERC20.sol";



contract DeployMockERC20 is Script {
    
    MockERC20 public currencyHubChain;




    function setUp() public {}

    function run() public {

        //uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast();

        currencyHubChain = new MockERC20("USDC", "USDC");

    

        console.log("-------- DEPLOYMENT --------");
        console.log("Chain Id: ", block.chainid);
        console.log("currency address: ", address(currencyHubChain)); 

        vm.stopBroadcast();
        
    }
}
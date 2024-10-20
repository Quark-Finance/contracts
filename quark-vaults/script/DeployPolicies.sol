// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";


import { QuarkNFT } from "../contracts/integrations/QuarkNFT.sol";

import { DepositPolicy } from "../contracts/policies/DepositPolicy.sol";
import { HyperdrivePolicy } from "../contracts/policies/HyperdrivePolicy.sol";
import { StoryPolicy } from "../contracts/policies/StoryPolicy.sol";


contract DeployMockERC20 is Script {

    DepositPolicy depositPolicy;
    HyperdrivePolicy hyperdrivePolicy;
    StoryPolicy storyPolicy;

    QuarkNFT quarkNFT;
    

    function setUp() public {}

    function run() public {

        //uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast();

        quarkNFT = new QuarkNFT();

        depositPolicy = new DepositPolicy(address(quarkNFT));

        hyperdrivePolicy = new HyperdrivePolicy();
        storyPolicy = new StoryPolicy();

        console.log("------ DEPLOYMENT POLCIES ---------");
        console.log("Chain ID: ", block.chainid);
        console.log("QuarkNFT Addres: ", address(quarkNFT));
        console.log("Deposit Policy: ", address(depositPolicy));
        console.log("Hyperdrive Policy: ", address(hyperdrivePolicy));
        console.log("Story Policy: ", address(storyPolicy));

        vm.stopBroadcast();
        
    }
}
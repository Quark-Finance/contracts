// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import { RegistrySpokeChain } from "../contracts/RegistrySpokeChain.sol";


contract DeployRegistrySpokeChainLineaSepolia is Script {

    RegistrySpokeChain public registrySpokeChain;


    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address owner = 0x000ef5F21dC574226A06C76AAE7060642A30eB74;
        address endpointSpokeChain = 0x6EDCE65403992e310A62460808c4b910D972f10f;

        address hubChainFactory =  0xbA397eFEF3914aB025F7f5706fADE61f240A9EbC;
        uint32 hubChainEid = 40333;

        registrySpokeChain = new RegistrySpokeChain(owner, endpointSpokeChain);

        registrySpokeChain.setHubChainFactoryPeer(hubChainEid, hubChainFactory);

        console.log("-------- Spoke Chain  DEPLOYMENT --------");
        console.log("Chain Id: ", block.chainid);
        console.log("Registry address: ", address(registrySpokeChain));
        

        vm.stopBroadcast();
        
    }
}
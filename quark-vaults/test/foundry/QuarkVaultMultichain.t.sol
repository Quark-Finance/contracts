// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import { QuarkHubChainAccount } from "../../contracts/QuarkHubChainAccount.sol";
import { QuarkFactory } from "../../contracts/QuarkFactory.sol";
import { MockERC20 } from "../../contracts/mocks/MockERC20.sol";

import { TestHelperOz5 } from "@layerzerolabs/test-devtools-evm-foundry/contracts/TestHelperOz5.sol";
import { RegistrySpokeChain } from "../../contracts/RegistrySpokeChain.sol";

import { RegistryHubChain } from "../../contracts/RegistryHubChain.sol";

import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

import { QuarkSpokeChainAccount } from "../../contracts/QuarkSpokeChainAccount.sol";

contract VaultTest is TestHelperOz5 {

    using OptionsBuilder for bytes;

    QuarkFactory public factory;
    MockERC20 public currency;
    RegistryHubChain public registry;
    RegistrySpokeChain registrySpoke1;
    RegistrySpokeChain registrySpoke2;

    uint32 private aEid = 1;
    uint32 private bEid = 2;
    uint32 private cEid = 3;

    uint256 public spokeChainId1 = 20;
    uint256 public spokeChainId2 = 30;


    address private userA = address(0x1);
    address private userB = address(0x2);

    uint128 GAS_LIMIT_SEND = 5000000;  //Gas limit for the executor
    uint128 MSG_VALUE_SEND = 10000000000000000; // msg.value for the lzReceive() function on destination in wei

    uint128 GAS_LIMIT_RETURN = 3000000;
    uint128 MSG_VALUE_RETURN = 0;
    
    function setUp() public override {

        vm.deal(userA, 1000 ether);
        vm.deal(userB, 1000 ether);

        super.setUp();
        setUpEndpoints(3, LibraryType.UltraLightNode);


        currency = new MockERC20("USDC", "USDC");

        registry = new RegistryHubChain(address(this));



        console.log("Owner address: ", address(this));
        //factory = new QuarkFactory(address(this), address(registry), address(currency), endpoints[aEid]);

        factory = QuarkFactory(
            _deployOApp(type(QuarkFactory).creationCode, abi.encode(address(this), address(registry), address(currency), endpoints[aEid]))
        );

        registrySpoke1 = RegistrySpokeChain(
            _deployOApp(type(RegistrySpokeChain).creationCode, abi.encode(address(this), endpoints[bEid]))
        );
        registrySpoke1.setHubChainFactoryPeer(aEid, address(factory));
        factory.setSpokeChainConfig(spokeChainId1, address(registrySpoke1), bEid);

        
        registrySpoke2 = RegistrySpokeChain(
            _deployOApp(type(RegistrySpokeChain).creationCode, abi.encode(address(this), endpoints[cEid]))
        );
        registrySpoke2.setHubChainFactoryPeer(aEid, address(factory));
        factory.setSpokeChainConfig(spokeChainId2, address(registrySpoke2), cEid);
        
    }


    function test_create_spoke_chain() public {
        uint256 vaultId = factory.createVault();

        QuarkHubChainAccount vault = QuarkHubChainAccount(payable(factory.quarkHubChainAccounts(vaultId)));

        vault.requestNewSpokeChain{ value: 13000000005010484 }(vaultId, spokeChainId1);

        verifyPackets(bEid, addressToBytes32(address(registrySpoke1)));

        verifyPackets(aEid, addressToBytes32(address(factory)));

        address spokeChainAccount = vault.spokeChainsAccounts(bEid);

        QuarkSpokeChainAccount(payable(spokeChainAccount)).updateValueToHubChain{ value: 2000000 }();

        verifyPackets(aEid, address(factory.quarkHubChainAccounts(vaultId)));

    }
}

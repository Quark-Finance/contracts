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

    uint32 private aEid = 1;
    uint32 private bEid = 2;


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
        setUpEndpoints(2, LibraryType.UltraLightNode);


        currency = new MockERC20("USDC", "USDC");

        registry = new RegistryHubChain(address(this));



        console.log("Owner address: ", address(this));
        //factory = new QuarkFactory(address(this), address(registry), address(currency), endpoints[aEid]);

        factory = QuarkFactory(
            _deployOApp(type(QuarkFactory).creationCode, abi.encode(address(this), address(registry), address(currency), endpoints[aEid]))
        );
        
    }

    function test_createVault() public {
        uint256 vaultId = factory.createVault("TEST", address(0), address(0));
        //address account = factory.quarkHubChainAccounts(vaultId);

        address owner = factory.ownerOf(vaultId);

        assertEq(owner, address(this));
    }

    function test_sendEth() public {
        uint256 vaultId = factory.createVault("TEST", address(0), address(0));
        address payable account = payable(factory.quarkHubChainAccounts(vaultId));

        uint256 balanceBefore = account.balance;
        (bool success, ) = account.call{value: 0.0001 ether}("");

        assertEq(success, true);
        uint256 balanceAfter = account.balance;
        assertEq(balanceAfter, balanceBefore + 0.0001 ether);

        (success, ) = account.call{ value: 1 ether} (
            abi.encodeWithSignature("execute(address,uint256,bytes,uint256)", vm.addr(1), 0.0000011 ether, "", 0)
        );

        assertEq(success, true);

    }

    function test_initialDeposit() public {

        uint256 vaultId = factory.createVault("TEST", address(0), address(0));
        address account = factory.quarkHubChainAccounts(vaultId);

        currency.mint(address(this), 1000 ether);
        currency.approve(payable(account), 1000 ether);

        QuarkHubChainAccount(payable(account)).deposit(1000 ether);

        uint256 price = 1;

        assertEq(currency.balanceOf(account), 1000 ether);
        assertEq(QuarkHubChainAccount(payable(account)).balanceOf(address(this)), 1000 ether / price);
    }

    function test_executeMint() public {

        uint256 vaultId = factory.createVault("TEST", address(0), address(0));
        QuarkHubChainAccount vault = QuarkHubChainAccount(payable(factory.quarkHubChainAccounts(vaultId)));

        vault.execute(address(currency), 0, abi.encodeWithSignature("mint(address,uint256)", vm.addr(1), 10 ether), 0);

        assertEq(currency.balanceOf(vm.addr(1)), 10 ether);

    }
}

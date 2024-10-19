// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import { QuarkHubChainAccount } from "../../contracts/QuarkHubChainAccount.sol";
import { QuarkFactory } from "../../contracts/QuarkFactory.sol";
import { SecuritySource } from "../../contracts/SecuritySource.sol";
import { MockERC20 } from "../../contracts/mocks/MockERC20.sol";
import { MockChainlinkDataFeed } from "../../contracts/mocks/MockChainlinkDataFeed.sol";

import { TestHelperOz5 } from "@layerzerolabs/test-devtools-evm-foundry/contracts/TestHelperOz5.sol";
import { RegistrySpokeChain } from "../../contracts/RegistrySpokeChain.sol";

import { RegistryHubChain } from "../../contracts/RegistryHubChain.sol";

import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

contract VaultTest is TestHelperOz5 {

    using OptionsBuilder for bytes;

    QuarkFactory public factory;
    MockERC20 public currency;
    RegistryHubChain public registry;

    SecuritySource public securitySource;

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
        securitySource = new SecuritySource(address(this));

        registry = new RegistryHubChain(address(this));



        console.log("Owner address: ", address(this));
        factory = new QuarkFactory(address(this), address(registry), address(currency), endpoints[aEid]);
        
    }

    // function test_createVault() public {
    //     uint256 vaultId = factory.createVault();
    //     //address account = factory.quarkHubChainAccounts(vaultId);

    //     address owner = factory.ownerOf(vaultId);

    //     assertEq(owner, address(this));
    // }

    // function test_sendEth() public {
    //     uint256 vaultId = factory.createVault();
    //     address payable account = payable(factory.quarkHubChainAccounts(vaultId));

    //     uint256 balanceBefore = account.balance;
    //     (bool success, ) = account.call{value: 0.0001 ether}("");

    //     assertEq(success, true);
    //     uint256 balanceAfter = account.balance;
    //     assertEq(balanceAfter, balanceBefore + 0.0001 ether);

    //     (success, ) = account.call{ value: 1 ether} (
    //         abi.encodeWithSignature("execute(address,uint256,bytes,uint256)", vm.addr(1), 0.0000011 ether, "", 0)
    //     );

    //     assertEq(success, true);

    // }

    // function test_whitelistTokens() public {

    //     MockERC20 token1 = new MockERC20("WBTC", "WBTC");
    //     MockERC20 token2 = new MockERC20("USDC", "USDC");

    //     //price feed mocked contracts
    //     MockChainlinkDataFeed priceFeed1 = new MockChainlinkDataFeed(6306055000000); // BTC / USD prices 8 decimals
    //     MockChainlinkDataFeed priceFeed2 = new MockChainlinkDataFeed(100000000); // USDC / USD prices 8 decimals

    //     //volatility feed mocked contracts
    //     MockChainlinkDataFeed volatilityFeed1 = new MockChainlinkDataFeed(67415); // BTC / USD  30 days volatitly 3 decimals on percentage -> 67415 = 67.415% vol
    //     MockChainlinkDataFeed volatilityFeed2 = new MockChainlinkDataFeed(0); // USDC / USD  30 days volatitly 3 decimals on percentage

    //     address[] memory tokens = new address[](2);
    //     tokens[0] = address(token1);
    //     tokens[1] = address(token2);

    //     address[] memory priceFeeds = new address[](2);
    //     priceFeeds[0] = address(priceFeed1);
    //     priceFeeds[1] = address(priceFeed2);

    //     address[] memory volatilityFeeds = new address[](2);
    //     volatilityFeeds[0] = address(volatilityFeed1);
    //     volatilityFeeds[1] = address(volatilityFeed2);


    //     securitySource.setWhitelistedERC20Tokens(tokens, priceFeeds, volatilityFeeds);

    //     assertEq(securitySource.numberWhitelistedERC20Tokens(), 2);

    //     assertEq(securitySource.whitelistedERC20Tokens(0), address(token1));
    //     assertEq(securitySource.whitelistedERC20Tokens(1), address(token2));

    //     assertEq(securitySource.priceFeedsWhitelistedERC20Tokens(0), address(priceFeed1));
    //     assertEq(securitySource.priceFeedsWhitelistedERC20Tokens(1), address(priceFeed2));

    //     assertEq(securitySource.volatilityFeedsWhitelistedERC20Tokens(0), address(volatilityFeed1));
    //     assertEq(securitySource.volatilityFeedsWhitelistedERC20Tokens(1), address(volatilityFeed2));
    // }

    // function test_initialDeposit() public {

    //     uint256 vaultId = factory.createVault();
    //     address account = factory.quarkHubChainAccounts(vaultId);

    //     currency.mint(address(this), 1000 ether);
    //     currency.approve(payable(account), 1000 ether);

    //     QuarkHubChainAccount(payable(account)).deposit(1000 ether);

    //     uint256 price = 1;

    //     assertEq(currency.balanceOf(account), 1000 ether);
    //     assertEq(QuarkHubChainAccount(payable(account)).balanceOf(address(this)), 1000 ether / price);
    // }


    // function test_depositAfterWBTCDeposit() public {

    //     MockERC20 token1 = new MockERC20("WBTC", "WBTC");

    //     //price feed mocked contracts
    //     MockChainlinkDataFeed priceFeed1 = new MockChainlinkDataFeed(6306055000000); // BTC / USD prices 8 decimals
    //     MockChainlinkDataFeed priceFeed2 = new MockChainlinkDataFeed(100000000); // USDC / USD prices 8 decimals

    //     //volatility feed mocked contracts
    //     MockChainlinkDataFeed volatilityFeed1 = new MockChainlinkDataFeed(67415); // BTC / USD  30 days volatitly 3 decimals on percentage -> 67415 = 67.415% vol
    //     MockChainlinkDataFeed volatilityFeed2 = new MockChainlinkDataFeed(0); // USDC / USD  30 days volatitly 3 decimals on percentage

    //     address[] memory tokens = new address[](2);
    //     tokens[0] = address(token1);
    //     tokens[1] = address(currency);

    //     address[] memory priceFeeds = new address[](2);
    //     priceFeeds[0] = address(priceFeed1);
    //     priceFeeds[1] = address(priceFeed2);

    //     address[] memory volatilityFeeds = new address[](2);
    //     volatilityFeeds[0] = address(volatilityFeed1);
    //     volatilityFeeds[1] = address(volatilityFeed2);

    //     securitySource.setWhitelistedERC20Tokens(tokens, priceFeeds, volatilityFeeds);

    //     factory.setSecuritySourceHubchain(address(securitySource));

    //     uint256 vaultId = factory.createVault();
    //     address account = factory.quarkHubChainAccounts(vaultId);

    //     currency.mint(address(this), 1000 ether);
    //     currency.approve(payable(account), 1000 ether);

    //     QuarkHubChainAccount(payable(account)).deposit(1000 ether);

    //     uint256 price = 1;

    //     assertEq(currency.balanceOf(account), 1000  ether);
    //     assertEq(QuarkHubChainAccount(payable(account)).balanceOf(address(this)), 1000 ether / price);

    //     //Send WBTC to the account

    //     token1.mint(account, 1 ether);

    //     (uint256 amount, ) = QuarkHubChainAccount(payable(account)).evaluateTotalValue();

    //     uint256 amountExpected;

    //     for(uint256 i = 0; i < tokens.length; i++) {
    //         uint256 balance = MockERC20(tokens[i]).balanceOf(account);
    //         (, int256 priceFromFeed, , , ) = MockChainlinkDataFeed(priceFeeds[i]).latestRoundData();
    //         amountExpected += balance * uint256(priceFromFeed) / 10 ** MockERC20(tokens[i]).decimals();
    //     }

    //     assertEq(amount, amountExpected);
    // }

    function test_createSpokeChainAccount() public{

        uint256 vaultId = factory.createVault();
        address account = factory.quarkHubChainAccounts(vaultId);

        bytes memory _optionsSend = OptionsBuilder.newOptions().addExecutorLzReceiveOption(GAS_LIMIT_SEND, MSG_VALUE_SEND);
        bytes memory _optionsReturn = OptionsBuilder.newOptions().addExecutorLzReceiveOption(GAS_LIMIT_RETURN, MSG_VALUE_RETURN);
        

        factory.createSpokeChainAccount{value: 13000000005010644}(vaultId, 1, _optionsSend, _optionsReturn);


        
    }
}

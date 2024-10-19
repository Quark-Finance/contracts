// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Create2.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


import { QuarkHubChainAccount } from "./QuarkHubChainAccount.sol";
import { SecuritySource } from "./SecuritySource.sol";

import { OApp, MessagingFee, Origin } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { MessagingReceipt } from "@layerzerolabs/oapp-evm/contracts/oapp/OAppSender.sol";
import { OAppOptionsType3 } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

interface IRegistryHubChain {
    function createHubChainAccount(address _initialOwner, address _endpoint) external returns (address);
}

//import { console } from "forge-std/Test.sol";

contract QuarkFactory is Ownable, OApp, OAppOptionsType3,  ERC721 {

    error InitializationFailed();

    using OptionsBuilder for bytes;

    address lzEndpoint;

    uint256 public vaultCounter;

    SecuritySource public securitySource;
    
    ERC20 public currencyToken;
    mapping(uint256 => address) public quarkHubChainAccounts;

    // not ERC6551
    IRegistryHubChain registry;

    uint16 public constant SEND = 1;
    uint16 public constant SEND_ABA = 2;

    //omnichain mappings
    mapping(uint256 => address) public spokeChainsRegistries; // ChainId to RegistrySpokeChain
    //mapping(uint256 => address) public spokeChainsImplementations; // ChainId to QuarkSpokeChainAccount

    mapping(uint256 => uint32) public spokeChainsIds; // ChainId to Eid


    //events
    event VaultCreated(address indexed owner, uint256 indexed vaultId, address indexed vaultAccount);
    event SecuritySourceSet(address indexed securitySource);
    event SpokeChainRegistered(uint256 indexed vaultId, uint256 chainId, uint64 nonce);

    //TODO OApp initializer
    constructor(address _initialOwner,  address _registry, address _currency, address _endpoint)  OApp(_endpoint, _initialOwner) ERC721("VaultHubChain", "VHC") Ownable(_initialOwner)  {
        currencyToken = ERC20(_currency);
        lzEndpoint = _endpoint;
        registry = IRegistryHubChain(_registry);
    }

    function setSecuritySourceHubchain(address _securitySource) public onlyOwner {
        securitySource = SecuritySource(_securitySource);
        emit SecuritySourceSet(_securitySource);
    }

    function createVault() public returns (uint256){
        uint256 vaultId = vaultCounter;

        vaultCounter++;

        _mint(address(this), vaultId);

        address vaultAccount = registry.createHubChainAccount(_msgSender(), lzEndpoint);

        QuarkHubChainAccount(payable(vaultAccount)).initializeAccount(address(this), address(currencyToken), address(securitySource));

        _transfer(address(this), msg.sender, vaultId);

        quarkHubChainAccounts[vaultId] = vaultAccount;

        emit VaultCreated(msg.sender, vaultId, vaultAccount);

        return vaultId;

    }


    function setSpokeChainConfig(uint256 chainId, address spokeChainRegistry, uint32 spokeChainEid) public onlyOwner {
        spokeChainsRegistries[chainId] = spokeChainRegistry;
        spokeChainsIds[chainId] = spokeChainEid;

        setPeer(spokeChainEid, bytes32(uint256(uint160(spokeChainRegistry))));
    }

    function _payNative(uint256 _nativeFee) internal override virtual returns (uint256 nativeFee) {
        if (msg.value < _nativeFee) revert NotEnoughNative(msg.value);
        return _nativeFee;
    }


    function createSpokeChainAccount(
            uint256 vaultId, 
            uint256 chainId, 
            bytes calldata _extraSendOptions, // gas settings for A -> B
            bytes calldata _extraReturnOptions
        ) public payable {
        
        //require(_msgSender() == quarkHubChainAccounts[vaultId], "Only vault account can call this function");

        uint128 GAS_LIMIT = 5000000; // Gas limit for the executor
        uint128 MSG_VALUE = 10000000000000000; // msg.value for the lzReceive() function on destination in wei

        

        uint32 dstEid = spokeChainsIds[chainId];

        bytes memory message = encodeMessage(_msgSender(),_extraReturnOptions);


        //bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(GAS_LIMIT, MSG_VALUE);


 
        bytes memory options = combineOptions(dstEid, SEND_ABA, _extraSendOptions);

        //MessagingFee memory fee = _quote(dstEid, message, options, false);

        MessagingReceipt memory receipt = _lzSend(
            dstEid,
            message,
            options,
            MessagingFee(msg.value, 0),
            payable(ownerOf(vaultId))
        );


        emit SpokeChainRegistered(vaultId, chainId,receipt.nonce);
    }

    function quote(
        uint32 _dstEid,
        bytes memory _message,
        bytes memory _options,
        bool _payInLzToken
    ) public view returns (MessagingFee memory fee) {
        bytes memory payload = abi.encode(_message);
        fee = _quote(_dstEid, payload, _options, _payInLzToken);
    }


    

    function encodeMessage(
        address hubChainAccount,
        bytes memory _extraReturnOptions
        ) public pure returns (bytes memory) {

        uint256 extraOptionsLength = _extraReturnOptions.length;

        return abi.encode(hubChainAccount, extraOptionsLength, _extraReturnOptions, extraOptionsLength);
    }

    function decodeMessage(bytes calldata encodedMessage) public pure returns (address hubChainAccount, address spokeChainAccount) {

        (hubChainAccount, spokeChainAccount) = abi.decode(encodedMessage, (address, address));
        
        return (hubChainAccount, spokeChainAccount);
    }


    function _lzReceive(
        Origin calldata _origin,
        bytes32 /*_guid*/,
        bytes calldata payload,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {

        (address hubChainAccount, address newSpokeChainAccount) = decodeMessage(payload);

        QuarkHubChainAccount(payable(hubChainAccount)).registerNewSpokeChain(_origin.srcEid, newSpokeChainAccount);

    }

    
     
}
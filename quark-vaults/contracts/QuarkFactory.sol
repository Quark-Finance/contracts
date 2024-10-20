// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Create2.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


import { QuarkHubChainAccount } from "./QuarkHubChainAccount.sol";

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
    
    ERC20 public currencyToken;
    mapping(uint256 => address) public quarkHubChainAccounts;


    uint128 public GAS_LIMIT_SEND_ABA = 5000000;
    uint128 public MSG_VALUE_SEND_ABA = 10000000000000000;

    // not ERC6551
    IRegistryHubChain registry;

    uint16 public constant SEND = 1;
    uint16 public constant SEND_ABA = 2;

    //omnichain mappings
    mapping(uint256 => address) public spokeChainsRegistries; // ChainId to RegistrySpokeChain

    mapping(uint256 => uint32) public spokeChainsIds; // ChainId to Eid



    //events
    event VaultCreated(address indexed owner, uint256 indexed vaultId, address indexed vaultAccount);
    event SpokeChainRegistered(uint256 indexed vaultId, uint256 chainId, uint64 nonce);
    event SpokeChainReceived(address indexed _spoke);

    //TODO OApp initializer
    constructor(address _initialOwner,  address _registry, address _currency, address _endpoint)  OApp(_endpoint, _initialOwner) ERC721("Quark Finance", "QFi") Ownable(_initialOwner)  {
        currencyToken = ERC20(_currency);
        lzEndpoint = _endpoint;
        registry = IRegistryHubChain(_registry);
    }

    function createVault(string memory _name, address _managementPolicy, address _depositPolicy) public returns (uint256){
        uint256 vaultId = vaultCounter;

        vaultCounter++;

        _mint(address(this), vaultId);

        address vaultAccount = registry.createHubChainAccount(_msgSender(), lzEndpoint);

        QuarkHubChainAccount(payable(vaultAccount)).initializeAccount(address(this), address(currencyToken), _name, _managementPolicy, _depositPolicy);

        _transfer(address(this), msg.sender, vaultId);

        quarkHubChainAccounts[vaultId] = vaultAccount;

        emit VaultCreated(msg.sender, vaultId, vaultAccount);

        return vaultId;

    }

    function setConfigParameterSendABA(uint128 _newGasLimit, uint128 _newMsgValue) public onlyOwner {
        GAS_LIMIT_SEND_ABA = _newGasLimit;
        MSG_VALUE_SEND_ABA = _newMsgValue;
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
            uint256 chainId
        ) public payable {
        
        require(_msgSender() == quarkHubChainAccounts[vaultId], "Only vault account can call this function");

        uint32 dstEid = spokeChainsIds[chainId];

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(GAS_LIMIT_SEND_ABA, MSG_VALUE_SEND_ABA);


        MessagingReceipt memory receipt = _lzSend(
            dstEid,
            encodeMessage(msg.sender, vaultId),
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
        uint256 vaultId
        ) public pure returns (bytes memory) {


        return abi.encode(hubChainAccount, vaultId);
    }

    function decodeMessage(bytes calldata encodedMessage) public pure returns (address spokeChainAccount, uint256 vaultId) {

        (spokeChainAccount, vaultId) = abi.decode(encodedMessage, (address, uint256));
        
        return (spokeChainAccount, vaultId);

    }


    function _lzReceive(
        Origin calldata _origin,
        bytes32 /*_guid*/,
        bytes calldata payload,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {

        (address newSpokeChainAccount, uint256 vaultId) = decodeMessage(payload);

        emit SpokeChainReceived(newSpokeChainAccount);

        QuarkHubChainAccount(payable(quarkHubChainAccounts[vaultId])).registerNewSpokeChain(_origin.srcEid, newSpokeChainAccount);

    }
  
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import "@openzeppelin/contracts/access/Ownable.sol";


//import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/interfaces/AggregatorV3Interface.sol"; // Forge
import {AggregatorV3Interface} from "@layerzerolabs/toolbox-foundry/lib/foundry-chainlink-toolkit/lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; // Hardhat

import { QuarkFactory } from "./QuarkFactory.sol";

import { OApp, MessagingFee, Origin } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { MessagingReceipt } from "@layerzerolabs/oapp-evm/contracts/oapp/OAppSender.sol";
import { OAppOptionsType3 } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";


import { IManagementPolicy } from "./interfaces/IManagementPolicy.sol";
import { IDepositPolicy } from "./interfaces/IDepositPolicy.sol";



import { console } from "forge-std/Test.sol";

contract QuarkHubChainAccount is  Ownable, OApp, OAppOptionsType3, ERC20 {
    receive() external payable {}

    using OptionsBuilder for bytes;

    uint256 public state;
    QuarkFactory public factory;
    ERC20 public currencyToken;
    bool public isInitialized;

    uint32[] public spokeEids;

    uint256 public hubChainvalueLocked;
    uint256 public totalValueLocked;

    uint128 public GAS_LIMIT_SEND_ABA = 2000000;
    uint128 public MSG_VALUE_SEND_ABA = 0;

    IManagementPolicy public managementPolicy;
    IDepositPolicy public depositPolicy;

    mapping(uint256 => address) public spokeChainsImplementationsAccounts; // ChainId to SpokeChainAccount

    mapping(uint32 => address) public spokeChainsAccounts;

    mapping(uint32 => uint256) public spokeChainsValueLocked;


    string public vaultName;

    //modifiers
    modifier onlyFactory() {
        require(msg.sender == address(factory), "Only factory can call this function");
        _;
    }

    modifier onlyNotInitialized() {
        require(!isInitialized, "Already initialized");
        _;
    }

    //events
    event Initialized(address indexed factory, address indexed currency);
    event Deposit(address indexed depositor, uint256 amountInTokenCurrency, uint256 amountInQuota);
    event SpokeChainRegistered(uint256 indexed spokeChainId);
    event SpokeChainValueUpdated(uint32 indexed spokeChainEid, uint256 amount);

    constructor(address _initialOwner, address _endpoint)  ERC20("HubChain", "HubChain") Ownable(_initialOwner) OApp(_endpoint, _initialOwner){


    }

    //CUSTOM FUNCTIONS
    function initializeAccount(address _factory, address _currency, string memory _name, address _managementPolicy, address _depositPolicy) public onlyNotInitialized {
        //require(_isValidSigner(msg.sender), "Invalid signer");

        managementPolicy = IManagementPolicy(_managementPolicy);
        depositPolicy = IDepositPolicy(_depositPolicy);

        vaultName = _name;
        
        
        
        currencyToken = ERC20(_currency);
        factory = QuarkFactory(_factory);

        isInitialized = true;
        emit Initialized(_factory, _currency);
    }

    function setPeer(uint32 _eid, bytes32 _peer) public virtual override onlyFactory {
        _setPeer(_eid, _peer);
    }

    function requestNewSpokeChain(uint256 vaultId, uint256 chainId) public payable {
        require(_isValidSigner(msg.sender), "Invalid signer");
        //require(spokeChainsImplementationsAccounts[chainId] == address(0), "Spoke chain already registered");

        factory.createSpokeChainAccount{ value: msg.value  }(vaultId, chainId);
    }

    function registerNewSpokeChain(uint32 _eid, address spokeChainAddress) external onlyFactory {
        require(spokeChainsAccounts[_eid] == address(0), "Spoke Chain already registered");

        spokeChainsAccounts[_eid] = spokeChainAddress;

        setPeer(_eid, bytes32(uint256(uint160(spokeChainAddress))));

        emit SpokeChainRegistered(_eid);
    }

    
    function getQuotaPrice() public view returns (uint256) {
        if(totalSupply() == 0){
            return 1;
        }

        return totalValueLocked/totalSupply();
    }

    function deposit(uint256 _amountInCurrencyToken) public {

        if(address(depositPolicy) != address(0) && !depositPolicy.validDepositor(msg.sender)){
            revert("Depositor not allowed by policy");
        }

        uint256 amountInQuota = _amountInCurrencyToken / getQuotaPrice();

        currencyToken.transferFrom(msg.sender, address(this), _amountInCurrencyToken);

        _mint(msg.sender, amountInQuota);

        totalValueLocked += _amountInCurrencyToken;


        emit Deposit(msg.sender, _amountInCurrencyToken, amountInQuota);
    }

    function _lzReceive(
        Origin calldata _origin,
        bytes32 /*_guid*/,
        bytes calldata payload,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {

        uint256 amount = decodeMessage(payload);

        console.log("Received amount: ", amount);
        spokeChainsValueLocked[_origin.srcEid] = amount;


        emit SpokeChainValueUpdated(_origin.srcEid, amount);
        
    }

    function decodeMessage(bytes calldata encodedMessage) public pure returns (uint256 amount) {
        (amount) = abi.decode(encodedMessage, (uint256));
        
        return (amount);
    }

    function executeOnSpokeChain(
        uint32 _dstEid,
        address _to,
        bytes calldata data
    ) public payable  {
        require(_isValidSigner(msg.sender), "Invalid signer");

        

        if(address(managementPolicy) != address(0)){
            if(!managementPolicy.isContractAllowed(_dstEid, _to)){
                revert("Transaction not allowed by policy");
            }
        }

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(GAS_LIMIT_SEND_ABA, MSG_VALUE_SEND_ABA);

        _lzSend(
            _dstEid, 
            encodeMessage(_to, data),
            options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );

    }

    function encodeMessage(address _to, bytes memory data) public pure returns (bytes memory) {

        uint256 dataLength = data.length;

        return abi.encode(_to, dataLength, data, dataLength);

    }

    // STANDARD ERC6551 FUNCTIONS
    function execute(
        address to,
        uint256 value,
        bytes calldata data,
        uint256 operation
    ) external payable returns (bytes memory result) {
        require(_isValidSigner(msg.sender), "Invalid signer");
        require(operation == 0, "Only call operations are supported");


        ++state;

        bool success;
        (success, result) = to.call{value: value}(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function isValidSignature(bytes32 hash, bytes memory signature)
        external
        view
        returns (bytes4 magicValue)
    {
        bool isValid = SignatureChecker.isValidSignatureNow(owner(), hash, signature);

        if (isValid) {
            return IERC1271.isValidSignature.selector;
        }

        return "";
    }

    function _isValidSigner(address signer) internal view returns (bool) {
        return signer == owner();
    }

    function setTVLEmergency(uint256 _newValue) public onlyOwner {
        totalValueLocked = _newValue;
    }
}
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

import { console } from "forge-std/Test.sol";

contract QuarkSpokeChainAccount is Ownable, OApp, OAppOptionsType3 {
    receive() external payable {}

    using OptionsBuilder for bytes;

    uint256 public state;
    QuarkFactory public factory;
    ERC20 public currencyToken;
    bool public isInitialized;


    uint32 public hubChainEid;


    uint128 public GAS_LIMIT_SEND_ABA = 1000000;
    uint128 public MSG_VALUE_SEND_ABA = 0;


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
    event SpokeChainRegistered(address indexed spokeChainAccount, uint256 indexed spokeChainId);
    event PeerSetHubChain(address indexed hubChainAccount);
    event UpdatedValueToHubChain(uint256 newValue);

    constructor(address _initialOwner, address _endpoint)  Ownable(_initialOwner) OApp(_endpoint, _initialOwner){


    }

    function setHubChainPeer(address _hubChainAccount, uint32 _hubChainEid) external onlyNotInitialized {
        isInitialized = true;
        hubChainEid = _hubChainEid;
        setPeer(_hubChainEid, bytes32(uint256(uint160(_hubChainAccount))));
    }

    function _lzReceive(
        Origin calldata _origin,
        bytes32 /*_guid*/,
        bytes calldata payload,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {
        
        (address to, uint256 dataStart, uint256 dataLength) = decodeMessage(payload);

        (bool success, bytes memory result) = to.call(payload[dataStart:dataStart+dataLength]);

        if(!success){
            revert("Unable to perform transaction");
        }

    }

    function decodeMessage(bytes calldata encodedMessage) public returns (address to, uint256 dataStart, uint256 dataLength) {

        (to, dataLength, dataStart) = abi.decode(encodedMessage, (address, uint256, uint256));

        dataStart +=32;

        console.log("to: ", to);

        return(to, dataStart, dataLength);
    }



    function updateValueToHubChain() public payable {

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(GAS_LIMIT_SEND_ABA, MSG_VALUE_SEND_ABA);

        _lzSend(
            hubChainEid,
            abi.encode(uint256(1000)),
            options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );

        emit UpdatedValueToHubChain(1000);


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

    // function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
    //     return (interfaceId == type(IERC165).interfaceId ||
    //         interfaceId == type(IERC6551Account).interfaceId ||
    //         interfaceId == type(IERC6551Executable).interfaceId);
    // }

    // function token()
    //     public
    //     view
    //     returns (
    //         uint256,
    //         address,
    //         uint256
    //     )
    // {
    //     bytes memory footer = new bytes(0x60);

    //     assembly {
    //         extcodecopy(address(), add(footer, 0x20), 0x4d, 0x60)
    //     }

    //     return abi.decode(footer, (uint256, address, uint256));
    // }

    // function owner() public view returns (address) {
    //     (uint256 chainId, address tokenContract, uint256 tokenId) = token();
    //     if (chainId != block.chainid) return address(0);

    //     return IERC721(tokenContract).ownerOf(tokenId);
    // }

    function _isValidSigner(address signer) internal view returns (bool) {
        return signer == owner();
    }
}
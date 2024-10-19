// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


import { OApp, MessagingFee, Origin } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { MessagingReceipt } from "@layerzerolabs/oapp-evm/contracts/oapp/OAppSender.sol";
import { QuarkSpokeChainAccount } from "./QuarkSpokeChainAccount.sol";


import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

import { OAppOptionsType3 } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";



contract RegistrySpokeChain is  OApp, OAppOptionsType3 {
    error InitializationFailed();

    using OptionsBuilder for bytes;


    address public lzEndpoint;

    uint16 public constant SEND = 1;
    uint16 public constant SEND_ABA = 2;

    //events
    event VaultSpokeChainRegistered(address indexed _spokeChainAccount, address indexed _hubChainAccount);


    constructor(address _initialOwner, address _endpoint) OApp(_endpoint, _initialOwner) Ownable(_initialOwner)  {
        lzEndpoint = _endpoint;
    }

    function setHubChainFactoryPeer(uint32 _hubChainEid, address _hubChainFactory) public onlyOwner {
        setPeer(_hubChainEid, bytes32(uint256(uint160(_hubChainFactory))));
    }

    function _payNative(uint256 _nativeFee) internal override virtual returns (uint256 nativeFee) {
        if (msg.value < _nativeFee) revert NotEnoughNative(msg.value);
        return _nativeFee;
    }

    

    function _lzReceive(
        Origin calldata _origin,
        bytes32 /*_guid*/,
        bytes calldata payload,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {
        (address hubChainAccount, uint256 extraOptionsStart, uint256 extraOptionsLength) = decodeMessage(payload);
        
        address newSpokeChainAccount = address(new QuarkSpokeChainAccount(address(this), lzEndpoint));

        QuarkSpokeChainAccount(payable(newSpokeChainAccount)).setHubChainPeer(hubChainAccount, _origin.srcEid);

        //uint128 GAS_LIMIT = 1000000; // Gas limit for the executor
        //uint128 MSG_VALUE = 0; // msg.value for the lzReceive() function on destination in wei


        bytes memory message = encodeMessage(hubChainAccount, newSpokeChainAccount);

        //bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(GAS_LIMIT, MSG_VALUE);

        bytes memory _options = combineOptions(_origin.srcEid, SEND, payload[extraOptionsStart:extraOptionsStart + extraOptionsLength]);


        _lzSend(
            _origin.srcEid,
            message,
            _options,
            MessagingFee(msg.value, 0),
            payable(newSpokeChainAccount)
        );

        emit VaultSpokeChainRegistered(newSpokeChainAccount, hubChainAccount);
    }

    function decodeMessage(bytes calldata encodedMessage) public pure returns (address hubChainAccount, uint256 extraOptionsStart, uint256 extraOptionsLength) {

        extraOptionsStart = 256; 
        (hubChainAccount, extraOptionsLength) = abi.decode(encodedMessage, (address, uint256));
        
        return (hubChainAccount, extraOptionsStart, extraOptionsLength);
    }

    function encodeMessage(
        address _hubChainAccount,
        address _spokeChainAccount
        ) public pure returns (bytes memory) {

        return abi.encode(_hubChainAccount, _spokeChainAccount);
    }


    
}
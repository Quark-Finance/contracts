// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";



import { QuarkHubChainAccount } from "./QuarkHubChainAccount.sol";




contract RegistryHubChain is Ownable {
    error InitializationFailed();


    constructor(address _initialOwner) Ownable(_initialOwner)  {}


    function createHubChainAccount(address _initialOwner, address _endpoint) public returns (address){

        address vaultAccount = address(new QuarkHubChainAccount(_initialOwner, _endpoint));

        return vaultAccount;

    }

   


    
}
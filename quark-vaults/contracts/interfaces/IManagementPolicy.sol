// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;




interface IManagementPolicy {

    function numberAllowedTokens(uint256 _chainId) external view returns (uint256);
    function getAllowedTokenAddress(uint256 _chainId, uint256 _id) external view returns (address);
    function getAllowedOracleAddress(uint256 _chainId, uint256 _id) external view returns (address);

    function isContractAllowed(uint256 _chainId, address _contractAddress) external view returns (bool);

}

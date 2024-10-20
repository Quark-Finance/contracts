// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IDepositPolicy } from "../interfaces/IDepositPolicy.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";



contract DepositPolicy is IDepositPolicy {

    IERC721 public nftContract;

    constructor(address _nftContract) {
        nftContract = IERC721(_nftContract);
    }

    function validDepositor(address _depositor) public view returns (bool) {
        return nftContract.balanceOf(_depositor) > 0;
    }

}
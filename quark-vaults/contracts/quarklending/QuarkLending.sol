// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { QuarkFactory } from "../QuarkFactory.sol";
import { QuarkHubChainAccount } from "../QuarkHubChainAccount.sol";

import { MockERC20 } from "../mocks/MockERC20.sol";


contract QuarkLending {

    address public currency;
    address public vaultFactory;

    mapping(uint256 => uint256) supplyUSDCPerVault;
    mapping(uint256 => uint256) collateralPerVault;

    event SupplyAdded(uint256 indexed vaultId, uint256 amount);

    constructor(address _currency, address _factory) {
        currency = _currency;
        vaultFactory = _factory;
    }

    function supply(uint256 vaultId, uint256 amount) public {

        ERC20(currency).transferFrom(msg.sender, address(this), amount);

        supplyUSDCPerVault[vaultId] += amount;

        emit SupplyAdded(vaultId, amount);

    }

    function borrow(uint256 vaultId, uint256 amountToBorrow, uint256 amountCollateral) public {

        address vaultAddress = QuarkFactory(vaultFactory).quarkHubChainAccounts(vaultId);


        QuarkHubChainAccount vault = QuarkHubChainAccount(payable(vaultAddress));

        if(vault.balanceOf(msg.sender) < amountCollateral) {
            revert("Not enough collateral");
        }

        vault.transferFrom(msg.sender, address(this), amountCollateral);

        collateralPerVault[vaultId] += amountCollateral;

        uint256 valueUser = (vault.totalValueLocked()/vault.totalSupply()) * amountCollateral;

        if(valueUser > 9 * amountToBorrow/10){
            revert("Not enough collateral on borrow");
        }

        ERC20(currency).transfer(msg.sender, amountToBorrow);


    }

}
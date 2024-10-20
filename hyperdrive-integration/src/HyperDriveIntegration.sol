// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.22;

import {console2 as console} from "forge-std/console2.sol";
import {IHyperdrive} from "hyperdrive/contracts/src/interfaces/IHyperdrive.sol";
import {FixedPointMath, ONE} from "hyperdrive/contracts/src/libraries/FixedPointMath.sol";
import {HyperdriveMath} from "hyperdrive/contracts/src/libraries/HyperdriveMath.sol";
import {Lib} from "hyperdrive/test/utils/Lib.sol";
import {HyperdriveUtils} from "hyperdrive/test/utils/HyperdriveUtils.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @notice A hello world use of Hyperdrive.
contract HyperDriveIntegration {
    using FixedPointMath for uint256;
    using HyperdriveUtils for IHyperdrive;
    using Lib for uint256;
    using SafeERC20 for ERC20;

    /// @notice The Hyperdrive instance this example utilizes.
    IHyperdrive public immutable hyperdrive;

    /// @notice Instantiates the Example contract.
    constructor(IHyperdrive _hyperdrive) {
        hyperdrive = _hyperdrive;
    }

    /// @notice Opens a long on Hyperdrive.
    function openLongHyperDrive(uint256 baseAmount) external {
        // Take custody of a user's assets and approve Hyperdrive to spend the
        // funds.
        ERC20 baseToken = ERC20(hyperdrive.baseToken());

        baseToken.approve(address(this), baseAmount);

        baseToken.transferFrom(msg.sender, address(this), baseAmount);
        baseToken.approve(address(hyperdrive), baseAmount);

        // Open a long position on Hyperdrive.
        (uint256 maturityTime, uint256 longAmount) = hyperdrive.openLong(
            baseAmount, // base paid
            baseAmount, // the minimum output -- this is a slippage guard
            hyperdrive
                .getCheckpoint(hyperdrive.latestCheckpoint())
                .vaultSharePrice, // the minimum vault share price -- this is a negative interest guard
            IHyperdrive.Options({
                asBase: true, // pay for the deposit with the base asset
                destination: msg.sender, // send the long position to the sender
                extraData: "" // no extra data for this yield source
            })
        );
    }
}
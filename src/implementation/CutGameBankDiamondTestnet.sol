// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {CutGameBankDiamond} from "./CutGameBankDiamond.sol";
import {ResourceLocatorSetterDiamond} from "../../lib/cu-osc-common/src/implementations/ResourceLocatorSetterDiamond.sol";
import {GameBankInitializerFragment} from "./GameBankInitializerFragment.sol";
import {WithdrawFragment} from "./WithdrawFragment.sol";

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract CutGameBankDiamondTestnet is
    CutGameBankDiamond,
    ResourceLocatorSetterDiamond,
    GameBankInitializerFragment,
    WithdrawFragment
{}

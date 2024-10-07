// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {CutDiamond} from "../../lib/cu-osc-diamond-template/src/diamond/CutDiamond.sol";
import {AccessBadgeDiamond} from "../../lib/cu-osc-common/src/implementations/AccessBadgeDiamond.sol";
import {ResourceLocatorGetterDiamond} from "../../lib/cu-osc-common/src/implementations/ResourceLocatorGetterDiamond.sol";
import {DarkMarksControllerFragment} from "./DarkMarksControllerFragment.sol";
import {ERC1155TokenReceiverFragment} from "./ERC1155TokenReceiverFragment.sol";
import {KeystoneStashFragment} from "./KeystoneStashFragment.sol";
import {LootBoxFragment} from "./LootBoxFragment.sol";
import {StashFragment} from "./StashFragment.sol";
import {TerminusStashFragment} from "./TerminusStashFragment.sol";
import {UNIMControllerFragment} from "./UNIMControllerFragment.sol";

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract CutGameBankDiamond is
    CutDiamond,
    AccessBadgeDiamond,
    ResourceLocatorGetterDiamond,
    DarkMarksControllerFragment,
    ERC1155TokenReceiverFragment,
    KeystoneStashFragment,
    LootBoxFragment,
    StashFragment,
    TerminusStashFragment,
    UNIMControllerFragment
{}

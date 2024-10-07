// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IPermissionProvider} from "../../lib/cu-osc-common/src/interfaces/IPermissionProvider.sol";
import {LibTerminusStash} from "../libraries/LibTerminusStash.sol";

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract TerminusStashFragment {
    event TerminusPoolStashedIn(
        address indexed player,
        address terminusAddress,
        uint256 poolId,
        uint256 indexed roundTripId,
        uint256 amount
    );

    event TerminusPoolStashedOut(
        address indexed player,
        address terminusAddress,
        uint256 poolId,
        uint256 indexed roundTripId,
        uint256 amount
    );

    event TerminusPoolCreated(
        address indexed terminusAddress,
        uint256 indexed poolId,
        bool canStashIn,
        bool canStashOut,
        IPermissionProvider.Permission stashInPermission,
        IPermissionProvider.Permission stashOutPermission
    );

    event TerminusPoolUpdated(
        address indexed terminusAddress,
        uint256 indexed poolId,
        bool canStashIn,
        bool canStashOut,
        IPermissionProvider.Permission stashInPermission,
        IPermissionProvider.Permission stashOutPermission
    );

    event TerminusPoolToggled(
        address indexed terminusAddress,
        uint256 indexed poolId,
        bool enabled
    );

    function stashInTerminusPoolGenerateMessageHash(
        address caller,
        address owner,
        address terminusAddress,
        uint256 poolId,
        uint256 amount,
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {}

    function stashInTerminusPoolWithSignature(
        address owner,
        address terminusAddress,
        uint256 poolId,
        uint256 amount,
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {}

    function toggleEnableTerminusPool(
        address terminusAddress,
        uint256 poolId
    ) external {}

    function createTerminusPool(
        address terminusAddress,
        uint256 poolId,
        IPermissionProvider.Permission stashInPermission,
        IPermissionProvider.Permission stashOutPermission,
        bool canStashIn,
        bool canStashOut
    ) external {}

    function updateTerminusPool(
        address terminusAddress,
        uint256 poolId,
        IPermissionProvider.Permission stashInPermission,
        IPermissionProvider.Permission stashOutPermission,
        bool canStashIn,
        bool canStashOut
    ) external {}

    function stashOutTerminusPoolGenerateMessageHash(
        address caller,
        address owner,
        address terminusAddress,
        uint256 poolId,
        uint256 amount,
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {}

    function stashOutTerminusPoolWithSignature(
        address owner,
        address terminusAddress,
        uint256 poolId,
        uint256 amount,
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {}

    function getTerminusPoolConfiguration(
        address terminusAddress,
        uint256 poolId
    )
        external
        view
        returns (
            LibTerminusStash.TerminusPoolConfiguration
                memory terminusPoolConfiguration
        )
    {}
}

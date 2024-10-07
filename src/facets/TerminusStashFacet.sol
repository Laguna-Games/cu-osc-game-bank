// SPDX-License-Identifier: Apache-2.0

/**
 * Author: Facundo
 *
 */

pragma solidity 0.8.19;

import {SignatureChecker} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";
import {IPermissionProvider} from "../../lib/cu-osc-common/src/interfaces/IPermissionProvider.sol";

import {LibTerminusStash} from "../libraries/LibTerminusStash.sol";
import {LibBank} from "../libraries/LibBank.sol";
import {LibServerSideSigning} from "../../lib/cu-osc-common/src/libraries/LibServerSideSigning.sol";
import {LibDiamond} from "../../lib/cu-osc-diamond-template/src/libraries/LibDiamond.sol";
import {LibPermissions} from "../libraries/LibPermissions.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";
import {LibEnvironment} from "../../lib/cu-osc-common/src/libraries/LibEnvironment.sol";
import {LibGasReturner} from "../../lib/cu-osc-common/src/libraries/LibGasReturner.sol";
import {LibValidate} from "../../lib/cu-osc-common/src/libraries/LibValidate.sol";
import {LibAccessBadge} from "../../lib/cu-osc-common/src/libraries/LibAccessBadge.sol";

contract TerminusStashFacet {
    function stashInTerminusPoolGenerateMessageHash(
        address caller,
        address owner,
        address terminusAddress,
        uint256 poolId,
        uint256 amount,
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "stashInTerminusPoolGenerateMessageHash(address caller, address owner, address terminusAddress, uint256 poolId, uint256 amount, uint256 roundTripId, uint256 bundleId, uint256 blockDeadline)"
                ),
                caller,
                owner,
                terminusAddress,
                poolId,
                amount,
                roundTripId,
                bundleId,
                blockDeadline
            )
        );
        bytes32 digest = LibServerSideSigning._hashTypedDataV4(structHash);
        return digest;
    }

    function stashInTerminusPoolWithSignature(
        address owner,
        address terminusAddress,
        uint256 poolId,
        uint256 amount,
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {
        uint256 availableGas = gasleft();
        IPermissionProvider.Permission permission = LibTerminusStash
            .getStashInPermissionForPool(terminusAddress, poolId);

        // Permission=0 is not NONE, it's a permission (FARM_ALLOWED), but in this case, that permission will NEVER be used for stashing, so we can use it as NONE/empty.
        require(
            permission != IPermissionProvider.Permission(0),
            "TerminusStashFacet: stashInTerminusPoolWithSignature -- Pool does not have a permission assigned"
        );

        LibPermissions.enforceCallerIsAccountOwnerOrHasPermission(
            owner,
            permission
        );

        bytes32 hash = stashInTerminusPoolGenerateMessageHash(
            msg.sender,
            owner,
            terminusAddress,
            poolId,
            amount,
            roundTripId,
            bundleId,
            blockDeadline
        );

        address gameServer = LibResourceLocator.gameServerSSS();
        require(
            SignatureChecker.isValidSignatureNow(gameServer, hash, signature),
            "TerminusStashFacet: stashInTerminusPoolWithSignature -- Payload must be signed by game server"
        );
        require(
            !LibServerSideSigning._checkRequest(bundleId),
            "TerminusStashFacet: stashInTerminusPoolWithSignature -- Request has already been fulfilled"
        );
        require(
            LibEnvironment.getBlockNumber() <= blockDeadline,
            "TerminusStashFacet: stashInTerminusPoolWithSignature -- Block deadline has expired"
        );
        LibServerSideSigning._completeRequest(bundleId);

        LibTerminusStash.stashInTerminusPool(
            owner,
            terminusAddress,
            poolId,
            roundTripId,
            amount
        );
        LibGasReturner.returnGasToUser(
            "stashInTerminusPoolWithSignature",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }

    function toggleEnableTerminusPool(
        address terminusAddress,
        uint256 poolId
    ) external {
        LibDiamond.enforceIsContractOwner();
        LibTerminusStash.toggleEnableTerminusPool(terminusAddress, poolId);
    }

    function createTerminusPool(
        address terminusAddress,
        uint256 poolId,
        IPermissionProvider.Permission stashInPermission,
        IPermissionProvider.Permission stashOutPermission,
        bool canStashIn,
        bool canStashOut
    ) external {
        LibDiamond.enforceIsContractOwner();
        LibTerminusStash.createTerminusPool(
            terminusAddress,
            poolId,
            stashInPermission,
            stashOutPermission,
            canStashIn,
            canStashOut
        );
    }

    function updateTerminusPool(
        address terminusAddress,
        uint256 poolId,
        IPermissionProvider.Permission stashInPermission,
        IPermissionProvider.Permission stashOutPermission,
        bool canStashIn,
        bool canStashOut
    ) external {
        LibDiamond.enforceIsContractOwner();
        LibTerminusStash.updateTerminusPool(
            terminusAddress,
            poolId,
            stashInPermission,
            stashOutPermission,
            canStashIn,
            canStashOut
        );
    }

    function stashOutTerminusPoolGenerateMessageHash(
        address caller,
        address owner,
        address terminusAddress,
        uint256 poolId,
        uint256 amount,
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "stashOutTerminusPoolGenerateMessageHash(address caller, address owner, address terminusAddress, uint256 poolId, uint256 amount, uint256 roundTripId, uint256 bundleId, uint256 blockDeadline)"
                ),
                caller,
                owner,
                terminusAddress,
                poolId,
                amount,
                roundTripId,
                bundleId,
                blockDeadline
            )
        );
        bytes32 digest = LibServerSideSigning._hashTypedDataV4(structHash);
        return digest;
    }

    function stashOutTerminusPoolWithSignature(
        address owner,
        address terminusAddress,
        uint256 poolId,
        uint256 amount,
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {
        IPermissionProvider.Permission permission = LibTerminusStash
            .getStashInPermissionForPool(terminusAddress, poolId);

        // Permission=0 is not NONE, it's a permission (FARM_ALLOWED), but in this case, that permission will NEVER be used for stashing, so we can use it as NONE/empty.
        require(
            permission != IPermissionProvider.Permission(0),
            "TerminusStashFacet: stashOutTerminusPoolWithSignature -- Pool doesn't have a permission assigned"
        );

        LibPermissions.enforceCallerIsAccountOwnerOrHasPermission(
            owner,
            LibTerminusStash.getStashOutPermissionForPool(
                terminusAddress,
                poolId
            )
        );
        bytes32 hash = stashOutTerminusPoolGenerateMessageHash(
            msg.sender,
            owner,
            terminusAddress,
            poolId,
            amount,
            roundTripId,
            bundleId,
            blockDeadline
        );

        address gameServer = LibResourceLocator.gameServerSSS();
        require(
            SignatureChecker.isValidSignatureNow(gameServer, hash, signature),
            "TerminusStashFacet: stashOutTerminusPoolWithSignature -- Payload must be signed by game server"
        );
        require(
            !LibServerSideSigning._checkRequest(bundleId),
            "TerminusStashFacet: stashOutTerminusPoolWithSignature -- Request has already been fulfilled"
        );
        require(
            LibEnvironment.getBlockNumber() <= blockDeadline,
            "TerminusStashFacet: stashOutTerminusPoolWithSignature -- Block deadline has expired"
        );
        LibServerSideSigning._completeRequest(bundleId);

        LibTerminusStash.stashOutTerminusPool(
            owner,
            terminusAddress,
            poolId,
            roundTripId,
            amount
        );
    }

    function batchMintForMultipleUsers(
        address[] calldata owners,
        address terminusAddress,
        uint256[][] calldata poolIds,
        uint256[][] calldata amounts
    ) public {
        LibAccessBadge.requireBadge("migrator");
        LibValidate.enforceNonEmptyAddressArray(owners);
        require(
            owners.length == poolIds.length && owners.length == amounts.length,
            "LibTerminusStash: batchStashOutTerminusPool -- array length mismatch"
        );
        LibTerminusStash.batchMintForMultipleUsers(
            owners,
            terminusAddress,
            poolIds,
            amounts
        );
    }

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
    {
        return
            LibTerminusStash.getTerminusPoolConfiguration(
                terminusAddress,
                poolId
            );
    }
}

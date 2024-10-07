// SPDX-License-Identifier: Apache-2.0

/**
 * Authors: Shiva
 * GitHub: https://github.com/ShivaLaguna
 *
 */

pragma solidity 0.8.19;

import {SignatureChecker} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";

import {LibTerminusToken} from "../libraries/LibTerminusToken.sol";
import {LibBank} from "../libraries/LibBank.sol";
import {LibServerSideSigning} from "../../lib/cu-osc-common/src/libraries/LibServerSideSigning.sol";
import {LibDiamond} from "../../lib/cu-osc-diamond-template/src/libraries/LibDiamond.sol";
import {LibPermissions, IPermissionProvider} from "../libraries/LibPermissions.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";
import {LibEnvironment} from "../../lib/cu-osc-common/src/libraries/LibEnvironment.sol";
import {LibGasReturner} from "../../lib/cu-osc-common/src/libraries/LibGasReturner.sol";

contract LootBoxFacet {
    function setLootboxIds(uint256[] calldata poolIds) external {
        LibDiamond.enforceIsContractOwner();
        LibTerminusToken.setLootboxIds(poolIds);
    }

    function StashLootBoxGenerateMessageHash(
        address caller,
        address owner,
        uint256 poolId,
        uint256 amount,
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "LootBoxPayload(address caller, address owner, uint256 poolId, uint256 amount, uint256 roundTripId, uint256 bundleId, uint256 blockDeadline)"
                ),
                caller,
                owner,
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

    function StashLootBoxWithSignature(
        address owner,
        uint256 poolId,
        uint256 amount,
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {
        uint256 availableGas = gasleft();
        LibPermissions.enforceCallerIsAccountOwnerOrHasPermission(
            owner,
            IPermissionProvider.Permission.BANK_STASH_LOOTBOX_IN_ALLOWED
        );
        bytes32 hash = StashLootBoxGenerateMessageHash(
            msg.sender,
            owner,
            poolId,
            amount,
            roundTripId,
            bundleId,
            blockDeadline
        );

        address gameServer = LibResourceLocator.gameServerSSS();
        require(
            SignatureChecker.isValidSignatureNow(gameServer, hash, signature),
            "LootBoxFacet: LootBoxWithSignature -- Payload must be signed by game server"
        );
        require(
            !LibServerSideSigning._checkRequest(bundleId),
            "LootBoxFacet: LootBoxWithSignature -- Request has already been fulfilled"
        );
        require(
            LibEnvironment.getBlockNumber() <= blockDeadline,
            "LootBoxFacet: LootBoxWithSignature -- Block deadline has expired"
        );
        LibServerSideSigning._completeRequest(bundleId);

        LibTerminusToken.stashLootBox(owner, poolId, roundTripId, amount);
        LibGasReturner.returnGasToUser(
            "StashLootBoxWithSignature",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }

    function isLootboxValid(uint256 pool) external view returns (bool) {
        return LibTerminusToken.isLootboxValid(pool);
    }

    function unsetLootboxIds(uint256[] calldata poolIds) external {
        LibDiamond.enforceIsContractOwner();
        LibTerminusToken.unsetLootboxIds(poolIds);
    }
}

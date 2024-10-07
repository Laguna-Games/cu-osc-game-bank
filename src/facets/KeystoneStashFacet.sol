// SPDX-License-Identifier: Apache-2.0

pragma solidity 0.8.19;

import {SignatureChecker} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";

import {LibTerminusToken} from "../libraries/LibTerminusToken.sol";
import {LibBank} from "../libraries/LibBank.sol";
import {LibServerSideSigning} from "../../lib/cu-osc-common/src/libraries/LibServerSideSigning.sol";
import {LibDiamond} from "../../lib/cu-osc-diamond-template/src/libraries/LibDiamond.sol";
import {LibPermissions, IPermissionProvider} from "../libraries/LibPermissions.sol";

import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";
import {LibEnvironment} from "../../lib/cu-osc-common/src/libraries/LibEnvironment.sol";

contract KeystoneStashFacet {
    function UnlockKeystoneFromGameGenerateMessageHash(
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
                    "UnlockKeystoneFromGamePayload(address caller, address owner, uint256 poolId, uint256 amount, uint256 roundTripId, uint256 bundleId, uint256 blockDeadline)"
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

    function UnlockKeystoneFromGameWithSignature(
        address owner,
        uint256 poolId,
        uint256 amount,
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {
        LibPermissions.enforceCallerIsAccountOwnerOrHasPermission(
            owner,
            IPermissionProvider.Permission.BANK_STASH_KEYSTONE_OUT_ALLOWED
        );
        bytes32 hash = UnlockKeystoneFromGameGenerateMessageHash(
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
            "KeystoneStashFacet: unlockKeystoneFromGameWithSignature -- Payload must be signed by game server"
        );
        require(
            !LibServerSideSigning._checkRequest(bundleId),
            "KeystoneStashFacet: unlockKeystoneFromGameWithSignature -- Request has already been fulfilled"
        );
        require(
            LibEnvironment.getBlockNumber() <= blockDeadline,
            "KeystoneStashFacet: unlockKeystoneFromGameWithSignature -- Block deadline has expired"
        );
        LibServerSideSigning._completeRequest(bundleId);
        LibTerminusToken._unlockKeystonesFromGame(
            owner,
            poolId,
            amount,
            roundTripId
        );
    }

    function setKeystonePoolIds(uint256[] calldata poolIds) external {
        LibDiamond.enforceIsContractOwner();
        LibTerminusToken.setKeystonePoolIds(poolIds);
    }

    function unsetKeystonePoolIds(uint256[] calldata poolIds) external {
        LibDiamond.enforceIsContractOwner();
        LibTerminusToken.unsetKeystonePoolIds(poolIds);
    }

    function keystonePoolIsValid(uint256 pool) external view returns (bool) {
        return LibTerminusToken.keystonePoolIsValid(pool);
    }
}

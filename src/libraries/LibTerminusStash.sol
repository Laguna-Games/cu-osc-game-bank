// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {LibDiamond} from "../../lib/cu-osc-diamond-template/src/libraries/LibDiamond.sol";
import {TerminusFacet} from "../../lib/dao/contracts/terminus/TerminusFacet.sol";
import {LibPermissions, IPermissionProvider} from "./LibPermissions.sol";

/// @title Terminus Stash Library
/// @notice This library is used to manage terminus stashes for the game bank.
/// @custom:storage-location erc7201:cryptounicorns.gamebank.terminusstash.storage
library LibTerminusStash {
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

    struct TerminusPoolConfiguration {
        bool enabled;
        bool canStashIn;
        bool canStashOut;
        IPermissionProvider.Permission stashInPermission;
        IPermissionProvider.Permission stashOutPermission;
    }

    /// @dev storage slot for the game bank terminus stash storage.
    bytes32 internal constant TERMINUS_STASH_STORAGE_POSITION =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("cryptounicorns.gamebank.terminusstash.storage")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    struct TerminusStashStorage {
        mapping(address terminusAddress => mapping(uint256 poolId => TerminusPoolConfiguration terminusPool)) terminusPools;
    }

    function terminusStashStorage()
        internal
        pure
        returns (TerminusStashStorage storage ts)
    {
        bytes32 position = TERMINUS_STASH_STORAGE_POSITION;
        assembly {
            ts.slot := position
        }
    }

    function stashInTerminusPool(
        address stasher,
        address terminusAddress,
        uint256 poolId,
        uint256 roundTripId,
        uint256 amount
    ) internal {
        TerminusPoolConfiguration
            memory terminusPool = getTerminusPoolConfiguration(
                terminusAddress,
                poolId
            );
        require(
            terminusPool.enabled,
            "LibTerminusStash: stashInTerminusPool -- Pool is disabled or doesn't exist"
        );
        require(
            terminusPool.canStashIn,
            "LibTerminusStash: stashInTerminusPool -- Pool can't be stashed in"
        );
        require(
            terminusAddress != address(0),
            "LibTerminusStash: stashInTerminusPool -- Terminus address is not set"
        );

        address bankAddress = address(this);

        TerminusFacet terminus = TerminusFacet(terminusAddress);
        terminus.safeTransferFrom(stasher, bankAddress, poolId, amount, "");

        emit TerminusPoolStashedIn(
            stasher,
            terminusAddress,
            poolId,
            roundTripId,
            amount
        );
    }

    function stashOutTerminusPool(
        address stasher,
        address terminusAddress,
        uint256 poolId,
        uint256 roundTripId,
        uint256 amount
    ) internal {
        TerminusPoolConfiguration
            memory terminusPool = getTerminusPoolConfiguration(
                terminusAddress,
                poolId
            );
        require(
            terminusPool.enabled,
            "LibTerminusStash: stashOutTerminusPool -- Pool is disabled or doesn't exist"
        );
        require(
            terminusPool.canStashOut,
            "LibTerminusStash: stashOutTerminusPool -- Pool can't be stashed out"
        );
        require(
            terminusAddress != address(0),
            "LibTerminusStash: stashOutTerminusPool -- Terminus address is not set"
        );

        address bankAddress = address(this);

        TerminusFacet terminus = TerminusFacet(terminusAddress);
        terminus.safeTransferFrom(bankAddress, stasher, poolId, amount, "");

        emit TerminusPoolStashedOut(
            stasher,
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
    ) internal {
        TerminusFacet terminus = TerminusFacet(terminusAddress);
        for (uint256 i = 0; i < owners.length; i++) {
            terminus.mintBatch(owners[i], poolIds[i], amounts[i], "");
        }
    }

    function createTerminusPool(
        address terminusAddress,
        uint256 poolId,
        IPermissionProvider.Permission stashInPermission,
        IPermissionProvider.Permission stashOutPermission,
        bool canStashIn,
        bool canStashOut
    ) internal {
        TerminusStashStorage storage ts = terminusStashStorage();

        ts.terminusPools[terminusAddress][poolId] = TerminusPoolConfiguration(
            true,
            canStashIn,
            canStashOut,
            stashInPermission,
            stashOutPermission
        );

        emit TerminusPoolCreated(
            terminusAddress,
            poolId,
            canStashIn,
            canStashOut,
            stashInPermission,
            stashOutPermission
        );
    }

    function toggleEnableTerminusPool(
        address terminusAddress,
        uint256 poolId
    ) internal {
        TerminusStashStorage storage ts = terminusStashStorage();

        ts.terminusPools[terminusAddress][poolId].enabled = !ts
        .terminusPools[terminusAddress][poolId].enabled;

        emit TerminusPoolToggled(
            terminusAddress,
            poolId,
            ts.terminusPools[terminusAddress][poolId].enabled
        );
    }

    function updateTerminusPool(
        address terminusAddress,
        uint256 poolId,
        IPermissionProvider.Permission stashInPermission,
        IPermissionProvider.Permission stashOutPermission,
        bool canStashIn,
        bool canStashOut
    ) internal {
        require(
            terminusAddress != address(0),
            "LibTerminusStash: updateTerminusPool -- Terminus address is required"
        );
        TerminusStashStorage storage ts = terminusStashStorage();
        ts.terminusPools[terminusAddress][poolId] = TerminusPoolConfiguration(
            true,
            canStashIn = canStashIn,
            canStashOut = canStashOut,
            stashInPermission = stashInPermission,
            stashOutPermission = stashOutPermission
        );

        emit TerminusPoolUpdated(
            terminusAddress,
            poolId,
            canStashIn,
            canStashOut,
            stashInPermission,
            stashOutPermission
        );
    }

    function getStashInPermissionForPool(
        address terminusAddress,
        uint256 poolId
    ) internal view returns (IPermissionProvider.Permission permission) {
        return
            terminusStashStorage()
            .terminusPools[terminusAddress][poolId].stashInPermission;
    }

    function getStashOutPermissionForPool(
        address terminusAddress,
        uint256 poolId
    ) internal view returns (IPermissionProvider.Permission permission) {
        return
            terminusStashStorage()
            .terminusPools[terminusAddress][poolId].stashOutPermission;
    }

    function getTerminusPoolConfiguration(
        address terminusAddress,
        uint256 poolId
    )
        internal
        view
        returns (LibTerminusStash.TerminusPoolConfiguration memory)
    {
        TerminusStashStorage storage ts = terminusStashStorage();
        return ts.terminusPools[terminusAddress][poolId];
    }
}

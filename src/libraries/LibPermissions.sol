// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IDelegatePermissions} from "../../lib/cu-osc-common/src/interfaces/IDelegatePermissions.sol";
import {IPermissionProvider} from "../../lib/cu-osc-common/src/interfaces/IPermissionProvider.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";

/// @title Permissions Library
/// @notice This library is used to manage permissions for the game bank.
/// @custom:storage-location erc7201:'cryptounicorns.gamebank.permissions.storage'
library LibPermissions {
    function getPermissionProvider()
        internal
        view
        returns (IDelegatePermissions)
    {
        return IDelegatePermissions(LibResourceLocator.playerProfile());
    }
    function allTrue(bool[] memory booleans) private pure returns (bool) {
        uint256 i = 0;
        while (i < booleans.length && booleans[i] == true) {
            i++;
        }
        return (i == booleans.length);
    }

    // pros: we reuse this function in every previous enforceCallerOwnsNFT.
    // cons: it's not generic
    function enforceCallerIsAccountOwnerOrHasPermissions(
        address delegator,
        IPermissionProvider.Permission[] memory permissions
    ) internal view {
        IDelegatePermissions pp = getPermissionProvider();

        //Sender is account owner or sender's delegator owns the assets and sender has specific permission for this action.
        require(
            delegator == msg.sender ||
                (delegator == pp.getDelegator(msg.sender) &&
                    pp.checkDelegatePermissions(delegator, permissions)),
            "LibPermissions: Must have permissions from delegator."
        );
    }

    function enforceCallerIsAccountOwnerOrHasPermission(
        address delegator,
        IPermissionProvider.Permission permission
    ) internal view {
        IDelegatePermissions pp = getPermissionProvider();

        //Sender is account owner or sender's delegator owns the assets and sender has specific permission for this action.
        require(
            delegator == msg.sender ||
                (delegator == pp.getDelegator(msg.sender) &&
                    pp.checkDelegatePermission(delegator, permission)),
            "LibPermissions: Must have permission from delegator."
        );
    }
}

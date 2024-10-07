// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {LibBank} from "./LibBank.sol";

import {LibContractOwner} from "../../lib/cu-osc-diamond-template/src/libraries/LibContractOwner.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";

interface IDarkMarksContract {
    function burnFrom(address account, uint256 amount) external;

    function mint(address account, uint256 amount) external;
}

/// @title Dark Marks Controller Library
/// @notice This library is used to manage the minting and burning of Dark Marks.
/// @custom:storage-location erc7201:'cryptounicorns.gamebank.darkmarks.storage'
library LibDarkMarksController {
    struct LibDarkMarksControllerStorage {
        address[] darkMarksControllers;
        mapping(address => uint256) darkMarksMintedByAddress;
        mapping(address => uint256) darkMarksBurnedByAddress;
    }

    event ControllerMintedDarkMarks(
        address indexed minter,
        uint256 amount,
        address indexed user
    );
    event ControllerBurnedDarkMarks(
        address indexed burner,
        uint256 amount,
        address indexed user
    );
    event AddedDarkMarksController(address indexed controller);
    event RemovedDarkMarksController(address indexed controller);

    /// @dev storage slot for the dark marks controller storage.
    bytes32 internal constant DARKMARKS_CONTROLLER_STORAGE_POSITION =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("cryptounicorns.gamebank.darkmarks.storage")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function darkMarksControllerStorage()
        internal
        pure
        returns (LibDarkMarksControllerStorage storage lucs)
    {
        bytes32 position = DARKMARKS_CONTROLLER_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            lucs.slot := position
        }
    }

    function enforceIsController() internal view {
        if (msg.sender == LibContractOwner.contractOwner()) {
            return;
        }

        LibDarkMarksControllerStorage
            storage lucs = darkMarksControllerStorage();
        for (uint256 i = 0; i < lucs.darkMarksControllers.length; i++) {
            if (msg.sender == lucs.darkMarksControllers[i]) {
                return;
            }
        }

        revert("LibDarkMarksController: Must be controller");
    }

    function addController(address controller) internal {
        LibDarkMarksControllerStorage
            storage lucs = darkMarksControllerStorage();

        for (uint256 i = 0; i < lucs.darkMarksControllers.length; i++) {
            if (lucs.darkMarksControllers[i] == controller) {
                revert("LibDarkMarksController: User is already controller");
            }
        }

        lucs.darkMarksControllers.push(controller);

        emit AddedDarkMarksController(controller);
    }

    function removeController(address controller) internal {
        LibDarkMarksControllerStorage
            storage lucs = darkMarksControllerStorage();

        for (uint256 i = 0; i < lucs.darkMarksControllers.length; i++) {
            if (lucs.darkMarksControllers[i] == controller) {
                lucs.darkMarksControllers[i] = lucs.darkMarksControllers[
                    lucs.darkMarksControllers.length - 1
                ];
                lucs.darkMarksControllers.pop();

                emit RemovedDarkMarksController(controller);
                return;
            }
        }

        revert("LibDarkMarksController: User is not controller");
    }

    function getControllers() internal view returns (address[] memory) {
        return darkMarksControllerStorage().darkMarksControllers;
    }

    function getDarkMarksOperationsForAddress(
        address user
    ) internal view returns (uint256 minted, uint256 burned) {
        LibDarkMarksControllerStorage
            storage lucs = darkMarksControllerStorage();

        return (
            lucs.darkMarksMintedByAddress[user],
            lucs.darkMarksBurnedByAddress[user]
        );
    }

    function mintDarkMarks(address account, uint256 amount) internal {
        increaseDarkMarksMintedByAddress(msg.sender, amount);

        IDarkMarksContract(LibResourceLocator.darkMarkToken()).mint(
            account,
            amount
        );

        emit ControllerMintedDarkMarks(msg.sender, amount, account);
    }

    function burnDarkMarksFrom(address account, uint256 amount) internal {
        increaseDarkMarksBurnedByAddress(msg.sender, amount);

        IDarkMarksContract(LibResourceLocator.darkMarkToken()).burnFrom(
            account,
            amount
        );

        emit ControllerBurnedDarkMarks(msg.sender, amount, account);
    }

    function increaseDarkMarksMintedByAddress(
        address minter,
        uint256 amount
    ) internal {
        darkMarksControllerStorage().darkMarksMintedByAddress[minter] += amount;
    }

    function increaseDarkMarksBurnedByAddress(
        address burner,
        uint256 amount
    ) internal {
        darkMarksControllerStorage().darkMarksBurnedByAddress[burner] += amount;
    }
}

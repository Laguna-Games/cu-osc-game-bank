// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {LibBank} from "./LibBank.sol";
import {LibContractOwner} from "../../lib/cu-osc-diamond-template/src/libraries/LibContractOwner.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";

interface IUNIMContract {
    function burnFrom(address account, uint256 amount) external;

    function mint(address account, uint256 amount) external;
}

/// @title UNIM Controller Library
/// @notice This library is used to manage the minting and burning of UNIM.
/// @custom:storage-location erc7201:'cryptounicorns.gamebank.unim.storage'
library LibUNIMController {
    struct LibUNIMControllerStorage {
        address[] unimControllers;
        mapping(address => uint256) unimMintedByAddress;
        mapping(address => uint256) unimBurnedByAddress;
    }

    event ControllerMintedUNIM(
        address indexed minter,
        uint256 amount,
        address indexed user
    );
    event ControllerBurnedUNIM(
        address indexed burner,
        uint256 amount,
        address indexed user
    );
    event AddedUNIMController(address indexed controller);
    event RemovedUNIMController(address indexed controller);

    /// @dev storage slot for the game bank unim storage.
    bytes32 internal constant UNIM_CONTROLLER_STORAGE_POSITION =
        keccak256(
            abi.encode(
                uint256(keccak256("cryptounicorns.gamebank.unim.storage")) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function unimControllerStorage()
        internal
        pure
        returns (LibUNIMControllerStorage storage lucs)
    {
        bytes32 position = UNIM_CONTROLLER_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            lucs.slot := position
        }
    }

    function enforceIsController() internal view {
        if (msg.sender == LibContractOwner.contractOwner()) {
            return;
        }

        LibUNIMControllerStorage storage lucs = unimControllerStorage();
        for (uint256 i = 0; i < lucs.unimControllers.length; i++) {
            if (msg.sender == lucs.unimControllers[i]) {
                return;
            }
        }

        revert("LibUNIMController: Must be controller");
    }

    function addController(address controller) internal {
        LibUNIMControllerStorage storage lucs = unimControllerStorage();

        for (uint256 i = 0; i < lucs.unimControllers.length; i++) {
            if (lucs.unimControllers[i] == controller) {
                revert("LibUNIMController: User is already controller");
            }
        }

        lucs.unimControllers.push(controller);

        emit AddedUNIMController(controller);
    }

    function removeController(address controller) internal {
        LibUNIMControllerStorage storage lucs = unimControllerStorage();

        for (uint256 i = 0; i < lucs.unimControllers.length; i++) {
            if (lucs.unimControllers[i] == controller) {
                lucs.unimControllers[i] = lucs.unimControllers[
                    lucs.unimControllers.length - 1
                ];
                lucs.unimControllers.pop();

                emit RemovedUNIMController(controller);
                return;
            }
        }

        revert("LibUNIMController: User is not controller");
    }

    function getControllers() internal view returns (address[] memory) {
        return unimControllerStorage().unimControllers;
    }

    function getUNIMOperationsForAddress(
        address user
    ) internal view returns (uint256 minted, uint256 burned) {
        LibUNIMControllerStorage storage lucs = unimControllerStorage();

        return (lucs.unimMintedByAddress[user], lucs.unimBurnedByAddress[user]);
    }

    function mintUNIM(address account, uint256 amount) internal {
        increaseUNIMMintedByAddress(msg.sender, amount);

        getUNIMContract().mint(account, amount);

        emit ControllerMintedUNIM(msg.sender, amount, account);
    }

    function burnUNIMFrom(address account, uint256 amount) internal {
        increaseUNIMBurnedByAddress(msg.sender, amount);

        getUNIMContract().burnFrom(account, amount);

        emit ControllerBurnedUNIM(msg.sender, amount, account);
    }

    function increaseUNIMMintedByAddress(
        address minter,
        uint256 amount
    ) internal {
        unimControllerStorage().unimMintedByAddress[minter] += amount;
    }

    function increaseUNIMBurnedByAddress(
        address burner,
        uint256 amount
    ) internal {
        unimControllerStorage().unimBurnedByAddress[burner] += amount;
    }

    function getUNIMContract() private view returns (IUNIMContract) {
        return IUNIMContract(LibResourceLocator.unimToken());
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
import {LibDiamond} from "../../lib/cu-osc-diamond-template/src/libraries/LibDiamond.sol";
import {TerminusFacet} from "../../lib/dao/contracts/terminus/TerminusFacet.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";

/// @title Terminus Token Library
/// @notice This library is used to manage terminus tokens for the game bank.
/// @custom:storage-location erc7201:cryptounicorns.gamebank.terminus.storage

library LibTerminusToken {
    event KeystoneUnlocked(
        address indexed playerWallet,
        uint256 indexed poolId,
        uint256 amount,
        uint256 indexed roundTripId
    );

    event KeystoneUnlockedV2(
        address indexed playerWallet,
        uint256 indexed poolId,
        uint256 amount,
        uint256 indexed roundTripId,
        address unlocker
    );

    event LootBoxStashed(
        address indexed player,
        address indexed token,
        uint256 indexed roundTripId,
        uint256 poolId,
        uint256 amount
    );

    event LootBoxStashedV2(
        address indexed player,
        address indexed token,
        uint256 indexed roundTripId,
        uint256 poolId,
        uint256 amount,
        address lootboxStasher
    );

    event SetLootboxPoolIds(uint256[] poolIds);

    event UnsetLootboxPoolIds(uint256[] poolIds);

    event SetKeyStonePoolIds(uint256[] poolIds);

    event UnsetKeyStonePoolIds(uint256[] poolIds);

    /// @dev storage slot for the game bank terminus storage.
    bytes32 internal constant TERMINUS_STORAGE_POSITION =
        keccak256(
            abi.encode(
                uint256(keccak256("cryptounicorns.gamebank.terminus.storage")) -
                    1
            )
        ) & ~bytes32(uint256(0xff));

    struct TerminusStorage {
        mapping(uint256 => bool) keystonePoolIds;
        mapping(uint256 => bool) lootboxPoolIds;
    }

    function terminusStorage()
        internal
        pure
        returns (TerminusStorage storage ts)
    {
        bytes32 position = TERMINUS_STORAGE_POSITION;
        assembly {
            ts.slot := position
        }
    }

    function setKeystonePoolIds(uint256[] calldata poolIds) internal {
        for (uint i = 0; i < poolIds.length; i++) {
            terminusStorage().keystonePoolIds[poolIds[i]] = true;
        }
        emit SetKeyStonePoolIds(poolIds);
    }

    function unsetKeystonePoolIds(uint256[] calldata poolIds) internal {
        for (uint i = 0; i < poolIds.length; i++) {
            require(keystonePoolIsValid(poolIds[i]), "Not Keystone PoolID");
            terminusStorage().keystonePoolIds[poolIds[i]] = false;
        }
        emit UnsetKeyStonePoolIds(poolIds);
    }

    function setLootboxIds(uint256[] calldata poolIds) internal {
        for (uint i = 0; i < poolIds.length; i++) {
            terminusStorage().lootboxPoolIds[poolIds[i]] = true;
        }
        emit SetLootboxPoolIds(poolIds);
    }

    function unsetLootboxIds(uint256[] calldata poolIds) internal {
        for (uint i = 0; i < poolIds.length; i++) {
            require(isLootboxValid(poolIds[i]), "Not Lootbox PoolID");
            terminusStorage().lootboxPoolIds[poolIds[i]] = false;
        }
        emit UnsetLootboxPoolIds(poolIds);
    }

    function isLootboxValid(uint256 pool) internal view returns (bool) {
        return terminusStorage().lootboxPoolIds[pool];
    }

    function keystonePoolIsValid(uint256 pool) internal view returns (bool) {
        return terminusStorage().keystonePoolIds[pool];
    }

    function stashLootBox(
        address stasher,
        uint256 poolId,
        uint256 roundTripId,
        uint256 amount
    ) internal {
        require(
            isLootboxValid(poolId),
            "LibTerminusToken: Desired pool is not a lootbox pool."
        );
        address tokenAddress = LibResourceLocator.unicornItems();
        TerminusFacet token = TerminusFacet(tokenAddress);
        burnToken(stasher, poolId, amount, token);
        emit LootBoxStashed(stasher, tokenAddress, roundTripId, poolId, amount);
        emit LootBoxStashedV2(
            stasher,
            tokenAddress,
            roundTripId,
            poolId,
            amount,
            msg.sender
        );
    }

    function burnToken(
        address account,
        uint256 poolId,
        uint256 value,
        TerminusFacet token
    ) internal {
        token.burn(account, poolId, value);
    }

    function _unlockKeystonesFromGame(
        address stasher,
        uint256 poolId,
        uint256 amount,
        uint256 roundTripId
    ) internal {
        require(
            keystonePoolIsValid(poolId),
            "LibTerminusToken: Desired pool is not a keystone pool."
        );

        TerminusFacet terminusContract = TerminusFacet(
            LibResourceLocator.unicornItems()
        );

        require(
            terminusContract.terminusPoolSupply(poolId) + amount <=
                terminusContract.terminusPoolCapacity(poolId),
            "LibTerminusToken: Desired amount is lower than the pool capacity allows."
        );

        terminusContract.mint(stasher, poolId, amount, "");
        emit KeystoneUnlocked(msg.sender, poolId, amount, roundTripId);
        emit KeystoneUnlockedV2(
            stasher,
            poolId,
            amount,
            roundTripId,
            msg.sender
        );
    }
}

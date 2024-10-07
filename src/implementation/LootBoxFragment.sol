// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract LootBoxFragment {
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

    function setLootboxIds(uint256[] calldata poolIds) external {}

    function StashLootBoxGenerateMessageHash(
        address caller,
        address owner,
        uint256 poolId,
        uint256 amount,
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {}

    function StashLootBoxWithSignature(
        address owner,
        uint256 poolId,
        uint256 amount,
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {}

    function isLootboxValid(uint256 pool) external view returns (bool) {}

    function unsetLootboxIds(uint256[] calldata poolIds) external {}
}

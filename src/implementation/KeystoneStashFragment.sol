// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract KeystoneStashFragment {
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

    event SetKeyStonePoolIds(uint256[] poolIds);

    event UnsetKeyStonePoolIds(uint256[] poolIds);

    function UnlockKeystoneFromGameGenerateMessageHash(
        address caller,
        address owner,
        uint256 poolId,
        uint256 amount,
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline
    ) public view returns (bytes32) {}

    function UnlockKeystoneFromGameWithSignature(
        address owner,
        uint256 poolId,
        uint256 amount,
        uint256 roundTripId,
        uint256 bundleId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {}

    function setKeystonePoolIds(uint256[] calldata poolIds) external {}

    function unsetKeystonePoolIds(uint256[] calldata poolIds) external {}

    function keystonePoolIsValid(uint256 pool) external view returns (bool) {}
}

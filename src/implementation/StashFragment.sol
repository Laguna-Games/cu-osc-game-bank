// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Dummy "implementation" contract for LG Diamond interface for ERC-1967 compatibility
/// @dev adapted from https://github.com/zdenham/diamond-etherscan?tab=readme-ov-file
/// @dev This interface is used internally to call endpoints on a deployed diamond cluster.
contract StashFragment {
    event Stashed(address indexed player, address indexed token, uint256 amount);

    event StashedV2(address indexed caller, address indexed token, uint256 amount, address indexed owner);

    event Unstashed(address indexed player, address indexed token, uint256 indexed requestId, uint256 amount);

    event UnstashedV2(
        address indexed caller,
        address indexed token,
        uint256 indexed requestId,
        uint256 amount,
        address owner
    );

    event StashedMultiple(address indexed player, address[] tokenAddresses, uint256[] tokenAmounts);

    event StashedMultipleV2(
        address indexed caller,
        address[] tokenAddresses,
        uint256[] tokenAmounts,
        address indexed owner
    );

    event UnstashedMultiple(
        address indexed player,
        uint256 indexed requestId,
        address[] tokenAddresses,
        uint256[] tokenAmounts
    );

    event UnstashedMultipleV2(
        address indexed caller,
        uint256 indexed requestId,
        address[] tokenAddresses,
        uint256[] tokenAmounts,
        address indexed owner
    );

    //OLD
    function stashUNIM(uint256 amount) external {}

    function stashUNIM(address owner, uint256 amount) public {}

    function unstashUNIMGenerateMessageHash(
        address caller,
        address owner,
        uint256 amount,
        uint256 requestId,
        uint256 blockDeadline
    ) public view returns (bytes32) {}

    //OLD
    function unstashUNIMWithSignature(
        uint256 amount,
        uint256 requestId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {}

    function unstashUNIMWithSignature(
        address owner,
        uint256 amount,
        uint256 requestId,
        uint256 blockDeadline,
        bytes memory signature
    ) public {}

    //OLD
    function stashRBW(uint256 amount) external {}

    function stashRBW(address owner, uint256 amount) public {}

    function unstashRBWGenerateMessageHash(
        address caller,
        address owner,
        uint256 amount,
        uint256 requestId,
        uint256 blockDeadline
    ) public view returns (bytes32) {}

    //OLD
    function unstashRBWWithSignature(
        uint256 amount,
        uint256 requestId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {}

    function unstashRBWWithSignature(
        address owner,
        uint256 amount,
        uint256 requestId,
        uint256 blockDeadline,
        bytes memory signature
    ) public {}

    //OLD
    function stashUNIMAndRBW(uint256 amountUNIM, uint256 amountRBW) external {}

    function stashUNIMAndRBW(address owner, uint256 amountUNIM, uint256 amountRBW) public {}

    function unstashUNIMAndRBWGenerateMessageHash(
        address caller,
        address owner,
        uint256 amountUNIM,
        uint256 amountRBW,
        uint256 requestId,
        uint256 blockDeadline
    ) public view returns (bytes32) {}

    //OLD
    function unstashUNIMAndRBWWithSignature(
        uint256 amountUNIM,
        uint256 amountRBW,
        uint256 requestId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {}

    function unstashUNIMAndRBWWithSignature(
        address owner,
        uint256 amountUNIM,
        uint256 amountRBW,
        uint256 requestId,
        uint256 blockDeadline,
        bytes memory signature
    ) public {}
}

// SPDX-License-Identifier: Apache-2.0

/**
 * Authors: Moonstream Engineering (engineering@moonstream.to)
 * GitHub: https://github.com/bugout-dev/dao
 *
 * Adapted from the ERC20 platform token for the Moonstream DAO.
 */

pragma solidity 0.8.19;

import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SignatureChecker} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";

import {LibBank} from "../libraries/LibBank.sol";
import {LibServerSideSigning} from "../../lib/cu-osc-common/src/libraries/LibServerSideSigning.sol";
import {LibDiamond} from "../../lib/cu-osc-diamond-template/src/libraries/LibDiamond.sol";
import {LibPermissions, IPermissionProvider} from "../libraries/LibPermissions.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";
import {LibEnvironment} from "../../lib/cu-osc-common/src/libraries/LibEnvironment.sol";
import {LibGasReturner} from "../../lib/cu-osc-common/src/libraries/LibGasReturner.sol";
import {LibDiamond} from "../../lib/cu-osc-diamond-template/src/libraries/LibDiamond.sol";
import {LibValidate} from "../../lib/cu-osc-common/src/libraries/LibValidate.sol";
import {LibAccessBadge} from "../../lib/cu-osc-common/src/libraries/LibAccessBadge.sol";
contract StashFacet {
    constructor() {}

    event Stashed(
        address indexed player,
        address indexed token,
        uint256 amount
    );

    event StashedV2(
        address indexed caller,
        address indexed token,
        uint256 amount,
        address indexed owner
    );

    event Unstashed(
        address indexed player,
        address indexed token,
        uint256 indexed requestId,
        uint256 amount
    );

    event UnstashedV2(
        address indexed caller,
        address indexed token,
        uint256 indexed requestId,
        uint256 amount,
        address owner
    );

    event StashedMultiple(
        address indexed player,
        address[] tokenAddresses,
        uint256[] tokenAmounts
    );

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
    function stashUNIM(uint256 amount) external {
        stashUNIM(msg.sender, amount);
    }

    function stashUNIM(address owner, uint256 amount) public {
        uint256 availableGas = gasleft();
        LibPermissions.enforceCallerIsAccountOwnerOrHasPermission(
            owner,
            IPermissionProvider.Permission.BANK_STASH_UNIM_IN_ALLOWED
        );
        address unimAddress = LibResourceLocator.unimToken();
        LibBank._stashERC20Token(unimAddress, owner, amount);
        emit Stashed(msg.sender, unimAddress, amount);
        emit StashedV2(msg.sender, unimAddress, amount, owner);
        LibGasReturner.returnGasToUser(
            "stashUNIM",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }

    function unstashUNIMGenerateMessageHash(
        address caller,
        address owner,
        uint256 amount,
        uint256 requestId,
        uint256 blockDeadline
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "UnstashUNIMPayload(address caller, address owner, uint256 amount, uint256 requestId, uint256 blockDeadline)"
                ),
                caller,
                owner,
                amount,
                requestId,
                blockDeadline
            )
        );
        bytes32 digest = LibServerSideSigning._hashTypedDataV4(structHash);
        return digest;
    }

    //OLD
    function unstashUNIMWithSignature(
        uint256 amount,
        uint256 requestId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {
        unstashUNIMWithSignature(
            msg.sender,
            amount,
            requestId,
            blockDeadline,
            signature
        );
    }

    function unstashUNIMWithSignature(
        address owner,
        uint256 amount,
        uint256 requestId,
        uint256 blockDeadline,
        bytes memory signature
    ) public {
        uint256 availableGas = gasleft();
        address unimAddress = LibResourceLocator.unimToken();

        LibPermissions.enforceCallerIsAccountOwnerOrHasPermission(
            owner,
            IPermissionProvider.Permission.BANK_STASH_UNIM_OUT_ALLOWED
        );
        bytes32 hash = unstashUNIMGenerateMessageHash(
            msg.sender,
            owner,
            amount,
            requestId,
            blockDeadline
        );
        address gameServer = LibResourceLocator.gameServerSSS();
        require(
            SignatureChecker.isValidSignatureNow(gameServer, hash, signature),
            "StashFacet: unstashUNIMWithSignature -- Payload must be signed by game server"
        );
        require(
            !LibServerSideSigning._checkRequest(requestId),
            "StashFacet: unstashUNIMWithSignature -- Request has already been fulfilled"
        );
        require(
            LibEnvironment.getBlockNumber() <= blockDeadline,
            "StashFacet: unstashUNIMWithSignature -- Block deadline has expired"
        );
        LibServerSideSigning._completeRequest(requestId);

        LibBank._unstashERC20Token(unimAddress, owner, amount);

        emit Unstashed(msg.sender, unimAddress, requestId, amount);
        emit UnstashedV2(msg.sender, unimAddress, requestId, amount, owner);
        LibGasReturner.returnGasToUser(
            "unstashUNIMWithSignature",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }

    //OLD
    function stashRBW(uint256 amount) external {
        stashRBW(msg.sender, amount);
    }

    function stashRBW(address owner, uint256 amount) public {
        uint256 availableGas = gasleft();
        LibPermissions.enforceCallerIsAccountOwnerOrHasPermission(
            owner,
            IPermissionProvider.Permission.BANK_STASH_RBW_IN_ALLOWED
        );
        address rbwAddress = LibResourceLocator.rbwToken();
        LibBank._stashERC20Token(rbwAddress, owner, amount);
        emit Stashed(msg.sender, rbwAddress, amount);
        emit StashedV2(msg.sender, rbwAddress, amount, owner);
        LibGasReturner.returnGasToUser(
            "stashRBW",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }

    function unstashRBWGenerateMessageHash(
        address caller,
        address owner,
        uint256 amount,
        uint256 requestId,
        uint256 blockDeadline
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "UnstashRBWPayload(address caller, address owner, uint256 amount, uint256 requestId, uint256 blockDeadline)"
                ),
                caller,
                owner,
                amount,
                requestId,
                blockDeadline
            )
        );
        bytes32 digest = LibServerSideSigning._hashTypedDataV4(structHash);
        return digest;
    }

    //OLD
    function unstashRBWWithSignature(
        uint256 amount,
        uint256 requestId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {
        unstashRBWWithSignature(
            msg.sender,
            amount,
            requestId,
            blockDeadline,
            signature
        );
    }

    function unstashRBWWithSignature(
        address owner,
        uint256 amount,
        uint256 requestId,
        uint256 blockDeadline,
        bytes memory signature
    ) public {
        uint256 availableGas = gasleft();
        LibPermissions.enforceCallerIsAccountOwnerOrHasPermission(
            owner,
            IPermissionProvider.Permission.BANK_STASH_RBW_OUT_ALLOWED
        );
        bytes32 hash = unstashRBWGenerateMessageHash(
            msg.sender,
            owner,
            amount,
            requestId,
            blockDeadline
        );
        address gameServer = LibResourceLocator.gameServerSSS();
        require(
            SignatureChecker.isValidSignatureNow(gameServer, hash, signature),
            "StashFacet: unstashRBWWithSignature -- Payload must be signed by game server"
        );
        require(
            !LibServerSideSigning._checkRequest(requestId),
            "StashFacet: unstashRBWWithSignature -- Request has already been fulfilled"
        );
        require(
            LibEnvironment.getBlockNumber() <= blockDeadline,
            "StashFacet: unstashRBWWithSignature -- Block deadline has expired"
        );
        LibServerSideSigning._completeRequest(requestId);
        address rbwAddress = LibResourceLocator.rbwToken();
        LibBank._unstashERC20Token(rbwAddress, owner, amount);

        emit Unstashed(msg.sender, rbwAddress, requestId, amount);
        emit UnstashedV2(msg.sender, rbwAddress, requestId, amount, owner);
        LibGasReturner.returnGasToUser(
            "unstashRBWWithSignature",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }

    //OLD
    function stashUNIMAndRBW(uint256 amountUNIM, uint256 amountRBW) external {
        stashUNIMAndRBW(msg.sender, amountUNIM, amountRBW);
    }

    function stashUNIMAndRBW(
        address owner,
        uint256 amountUNIM,
        uint256 amountRBW
    ) public {
        uint256 availableGas = gasleft();
        address unimAddress = LibResourceLocator.unimToken();
        address rbwAddress = LibResourceLocator.rbwToken();
        IPermissionProvider.Permission[]
            memory requiredPermissions = new IPermissionProvider.Permission[](
                2
            );
        requiredPermissions[0] = IPermissionProvider
            .Permission
            .BANK_STASH_RBW_IN_ALLOWED;
        requiredPermissions[1] = IPermissionProvider
            .Permission
            .BANK_STASH_UNIM_IN_ALLOWED;
        LibPermissions.enforceCallerIsAccountOwnerOrHasPermissions(
            owner,
            requiredPermissions
        );
        LibBank._stashERC20Token(unimAddress, owner, amountUNIM);
        LibBank._stashERC20Token(rbwAddress, owner, amountRBW);
        emit Stashed(msg.sender, unimAddress, amountUNIM);
        emit Stashed(msg.sender, rbwAddress, amountRBW);
        address[] memory tokenAddresses = new address[](2);
        uint256[] memory tokenAmounts = new uint256[](2);
        tokenAddresses[0] = unimAddress;
        tokenAddresses[1] = rbwAddress;
        tokenAmounts[0] = amountUNIM;
        tokenAmounts[1] = amountRBW;
        emit StashedMultiple(msg.sender, tokenAddresses, tokenAmounts);
        emit StashedMultipleV2(msg.sender, tokenAddresses, tokenAmounts, owner);
        LibGasReturner.returnGasToUser(
            "stashUNIMAndRBW",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }

    function unstashUNIMAndRBWGenerateMessageHash(
        address caller,
        address owner,
        uint256 amountUNIM,
        uint256 amountRBW,
        uint256 requestId,
        uint256 blockDeadline
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "UnstashUNIMAndRBWPayload(address caller, address owner, uint256 amountUNIM, uint256 amountRBW, uint256 requestId, uint256 blockDeadline)"
                ),
                caller,
                owner,
                amountUNIM,
                amountRBW,
                requestId,
                blockDeadline
            )
        );
        bytes32 digest = LibServerSideSigning._hashTypedDataV4(structHash);
        return digest;
    }

    //OLD
    function unstashUNIMAndRBWWithSignature(
        uint256 amountUNIM,
        uint256 amountRBW,
        uint256 requestId,
        uint256 blockDeadline,
        bytes memory signature
    ) external {
        unstashUNIMAndRBWWithSignature(
            msg.sender,
            amountUNIM,
            amountRBW,
            requestId,
            blockDeadline,
            signature
        );
    }

    function unstashUNIMAndRBWWithSignature(
        address owner,
        uint256 amountUNIM,
        uint256 amountRBW,
        uint256 requestId,
        uint256 blockDeadline,
        bytes memory signature
    ) public {
        uint256 availableGas = gasleft();
        IPermissionProvider.Permission[]
            memory requiredPermissions = new IPermissionProvider.Permission[](
                2
            );
        requiredPermissions[0] = IPermissionProvider
            .Permission
            .BANK_STASH_RBW_OUT_ALLOWED;
        requiredPermissions[1] = IPermissionProvider
            .Permission
            .BANK_STASH_UNIM_OUT_ALLOWED;
        LibPermissions.enforceCallerIsAccountOwnerOrHasPermissions(
            owner,
            requiredPermissions
        );
        bytes32 hash = unstashUNIMAndRBWGenerateMessageHash(
            msg.sender,
            owner,
            amountUNIM,
            amountRBW,
            requestId,
            blockDeadline
        );
        address gameServer = LibResourceLocator.gameServerSSS();
        address unimAddress = LibResourceLocator.unimToken();
        address rbwAddress = LibResourceLocator.rbwToken();
        require(
            SignatureChecker.isValidSignatureNow(gameServer, hash, signature),
            "StashFacet: unstashUNIMAndRBWWithSignature -- Payload must be signed by game server"
        );
        require(
            !LibServerSideSigning._checkRequest(requestId),
            "StashFacet: unstashUNIMAndRBWWithSignature -- Request has already been fulfilled"
        );
        require(
            LibEnvironment.getBlockNumber() <= blockDeadline,
            "StashFacet: unstashUNIMAndRBWWithSignature -- Block deadline has expired"
        );
        LibServerSideSigning._completeRequest(requestId);

        LibBank._unstashERC20Token(unimAddress, owner, amountUNIM);
        LibBank._unstashERC20Token(rbwAddress, owner, amountRBW);

        address[] memory tokenAddresses = new address[](2);
        uint256[] memory tokenAmounts = new uint256[](2);
        tokenAddresses[0] = unimAddress;
        tokenAddresses[1] = rbwAddress;
        tokenAmounts[0] = amountUNIM;
        tokenAmounts[1] = amountRBW;
        emit UnstashedMultiple(
            msg.sender,
            requestId,
            tokenAddresses,
            tokenAmounts
        );
        emit UnstashedMultipleV2(
            msg.sender,
            requestId,
            tokenAddresses,
            tokenAmounts,
            owner
        );
        LibGasReturner.returnGasToUser(
            "unstashUNIMAndRBWWithSignature",
            (availableGas - gasleft()),
            payable(msg.sender)
        );
    }

    function batchUnstashUNIMAndRBW(
        address[] calldata owners,
        uint256[] calldata amountsUNIM,
        uint256[] calldata amountsRBW
    ) public {
        LibAccessBadge.requireBadge("migrator");
        LibValidate.enforceNonEmptyAddressArray(owners);
        require(
            owners.length == amountsUNIM.length &&
                owners.length == amountsRBW.length,
            "StashFacet: batchUnstashUNIMAndRBW -- Arrays must be of equal length"
        );
        for (uint256 i = 0; i < owners.length; i++) {
            address owner = owners[i];
            uint256 amountUNIM = amountsUNIM[i];
            uint256 amountRBW = amountsRBW[i];
            address unimAddress = LibResourceLocator.unimToken();
            address rbwAddress = LibResourceLocator.rbwToken();
            LibBank._unstashERC20Token(unimAddress, owner, amountUNIM);
            LibBank._unstashERC20Token(rbwAddress, owner, amountRBW);
            emit Unstashed(msg.sender, unimAddress, 0, amountUNIM);
            emit Unstashed(msg.sender, rbwAddress, 0, amountRBW);
        }
    }
}

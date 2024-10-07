//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
import {IERC1155Receiver} from '../../lib/openzeppelin-contracts/contracts/token/ERC1155/IERC1155Receiver.sol';

contract ERC1155TokenReceiverFacet {
    function onERC1155Received(
        address, // operator
        address, // from
        uint256, // id
        uint256, // value
        bytes calldata // data
    ) external pure returns (bytes4) {
        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address, // operator
        address, // from
        uint256[] calldata, // ids
        uint256[] calldata, // values
        bytes calldata // data
    ) external pure returns (bytes4) {
        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }
}

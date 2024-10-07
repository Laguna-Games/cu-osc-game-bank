// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {LibDiamond} from "../../lib/cu-osc-diamond-template/src/libraries/LibDiamond.sol";

library LibBank {
    function _stashERC20Token(
        address tokenAddress,
        address stasher,
        uint256 amount
    ) internal {
        address bankAddress = address(this);
        IERC20 token = IERC20(tokenAddress);
        require(
            token.allowance(stasher, bankAddress) >= amount,
            "LibBank: _stashERC20Token -- Insufficient token allowance for Game Bank"
        );
        token.transferFrom(stasher, bankAddress, amount);
    }

    function _unstashERC20Token(
        address tokenAddress,
        address recipient,
        uint256 amount
    ) internal {
        address bankAddress = address(this);
        IERC20 token = IERC20(tokenAddress);
        require(
            token.balanceOf(bankAddress) >= amount,
            "LibBank: _unstashERC20Token -- Insufficient amount of tokens in reserve"
        );
        token.transfer(recipient, amount);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ERC20Burnable} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {LibDiamond} from "../../lib/cu-osc-diamond-template/src/libraries/LibDiamond.sol";
import {LibResourceLocator} from "../../lib/cu-osc-common/src/libraries/LibResourceLocator.sol";

contract WithdrawFacet {
    function withdrawUNIM(address payable receiver, uint256 amount) external {
        LibDiamond.enforceIsContractOwner();
        IERC20 UNIMToken = IERC20(LibResourceLocator.unimToken());
        UNIMToken.transfer(receiver, amount);
    }

    function withdrawRBW(address payable receiver, uint256 amount) external {
        LibDiamond.enforceIsContractOwner();
        IERC20 RBWToken = IERC20(LibResourceLocator.rbwToken());
        RBWToken.transfer(receiver, amount);
    }

    function burnUNIM(uint256 amount) external {
        LibDiamond.enforceIsContractOwner();
        ERC20Burnable UNIMToken = ERC20Burnable(LibResourceLocator.unimToken());
        UNIMToken.burn(amount);
    }

    function withdrawWETH(address payable receiver, uint256 amount) external {
        LibDiamond.enforceIsContractOwner();
        IERC20 WETHToken = IERC20(LibResourceLocator.wethToken());
        WETHToken.transfer(receiver, amount);
    }
}

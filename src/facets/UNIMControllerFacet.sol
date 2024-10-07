// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {LibDiamond} from "../../lib/cu-osc-diamond-template/src/libraries/LibDiamond.sol";
import {LibUNIMController} from "../libraries/LibUNIMController.sol";
import {IUNIMControllerFacet} from "../interfaces/IUNIMControllerFacet.sol";

contract UNIMControllerFacet is IUNIMControllerFacet {
    /*
     * @notice Whitelist a user or contract to create new UNIM tokens.
     * @dev Can only be called by the Diamond owner of the UNIM contract.
     * @param minter - Public address of the user or contract allow
     */
    function allowAddressToMintUNIM(address minter) external {
        LibDiamond.enforceIsContractOwner();

        LibUNIMController.addController(minter);
    }

    /*
     * @notice Revoke a user's or contract's permission to create new UNIM tokens.
     * @dev Can only be called by the Diamond owner of the UNIM contract.
     * @param minter - Public address of the user or contract to revoke
     */
    function denyAddressToMintUNIM(address minter) external {
        LibDiamond.enforceIsContractOwner();

        LibUNIMController.removeController(minter);
    }

    /*
     * @notice Print the list of wallets and contracts who can create UNIM tokens.
     * @return The full list of permitted addresses
     */
    function getAddressesPermittedToMintUNIM()
        external
        view
        returns (address[] memory)
    {
        return LibUNIMController.getControllers();
    }

    /*
     * @notice Reports the lifetime number of UNIM that an address has minted and burned.
     * @param controller - Public address of the controller to audit
     * @return minted - The grand total number of UNIM this address has minted
     * @return burned - The grand total number of UNIM this address has burned
     */
    function getUNIMOperationsForAddress(
        address controller
    ) external view returns (uint256 minted, uint256 burned) {
        return LibUNIMController.getUNIMOperationsForAddress(controller);
    }

    /*
     * @notice Create new UNIM tokens for a target wallet.
     * @dev Can only be called by an address allowed via allowAddressToMintUNIM
     * @param account - The address receiving the funds
     * @param amount - The number of UNIM tokens to create
     */
    function mintUNIM(address account, uint256 amount) external {
        LibUNIMController.enforceIsController();

        LibUNIMController.mintUNIM(account, amount);
    }

    /*
     * @notice Destroy UNIM tokens from a target wallet.
     * @dev Can only be called by an address allowed via allowAddressToMintUNIM
     * @dev This method uses the player's spend/burn allowance granted to GameBank,
     *     rather than allowance for msgSender, so this may have better permission.
     * @param account - The wallet to remove UNIM from
     * @param amount - The number of UNIM tokens to destroy
     */
    function burnUNIMFrom(address account, uint256 amount) external {
        LibUNIMController.enforceIsController();

        LibUNIMController.burnUNIMFrom(account, amount);
    }
}

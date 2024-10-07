// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface IDarkMarksControllerFacet {
    /*
     * @notice Whitelist a user or contract to create new DarkMarks tokens.
     * @dev Can only be called by the Diamond owner of the DarkMarks contract.
     * @param minter - Public address of the user or contract allow
     */
    function allowAddressToMintDarkMarks(address minter) external;

    /*
     * @notice Revoke a user's or contract's permission to create new DarkMarks tokens.
     * @dev Can only be called by the Diamond owner of the DarkMarks contract.
     * @param minter - Public address of the user or contract to revoke
     */
    function denyAddressToMintDarkMarks(address minter) external;

    /*
     * @notice Print the list of wallets and contracts who can create DarkMarks tokens.
     * @return The full list of permitted addresses
     */
    function getAddressesPermittedToMintDarkMarks() external view returns (address[] memory);

    /*
     * @notice Reports the lifetime number of DarkMarks that an address has minted and burned.
     * @param controller - Public address of the minter
     * @return minted - The grand total number of DarkMarks this address has minted
     * @return burned - The grand total number of DarkMarks this address has burned
     */
    function getDarkMarksOperationsForAddress(
        address controller
    ) external view returns (uint256 minted, uint256 burned);

    /*
     * @notice Create new DarkMarks tokens for a target wallet.
     * @dev Can only be called by an address allowed via allowAddressToMintDarkMarks
     * @param account - The address receiving the funds
     * @param amount - The number of DarkMarks tokens to create
     */
    function mintDarkMarks(address account, uint256 amount) external;

    /*
     * @notice Destroy DarkMarks tokens from a target wallet.
     * @dev Can only be called by an address allowed via allowAddressToMintDarkMarks
     * @dev This method uses the player's spend/burn allowance granted to GameBank,
     *     rather than allowance for msgSender, so this may have better permission.
     * @param account - The wallet to remove DarkMarks from
     * @param amount - The number of DarkMarks tokens to destroy
     */
    function burnDarkMarksFrom(address account, uint256 amount) external;
}

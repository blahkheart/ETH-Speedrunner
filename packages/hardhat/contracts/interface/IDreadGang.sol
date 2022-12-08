// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;
import "./IERC5050.sol";

/// @param lockAddress The address of the level to be unlocked
/// @param init The boolean that specifies whether or not a level is initalized
/// @param minAllowedLevel The minimum allowed level that can unlock the level
/// @param creator The address of the level creator
struct LevelUnlockData {
    address lockAddress;
    bool init;
    uint minAllowedLevel;
    address creator;
}

/// @param nood The bytes4(keccack256()) encoding of the action string
/// @param hustler The address of the sender
/// @param OG The initiating object
struct StreetCred {
    uint8 noob;
    uint32 hustler;
    uint256 OG;
}

interface IDreadGang is IERC5050 {
    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event LevelUp(
        address levelLock,
        uint256 indexed tokenId,
        uint256 indexed newLevel
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event CreateLevel(
        address indexed levelLock,
        uint256 indexed minAllowedLevel,
        address creator
    );

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getLevel(uint _tokenId) public view returns (uint256);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function isSquadMember(address _account) public view returns (bool);

    /**
     * @dev To create a new level lock
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {CreateLevel} event.
     */
    function createLevelUpLock(
        address _levelLockAddress,
        uint256 _minAllowedLevel
    ) public payable;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {LevelUp} event.
     */
    function levelUp(uint256 _tokenId) returns (uint256);
}

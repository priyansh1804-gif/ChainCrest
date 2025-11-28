// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title ChainCrest
 * @dev Simple on-chain badge & reputation registry
 * @notice Issuers award badges to addresses; badges carry scores used to compute reputation
 */
contract ChainCrest {
    address public owner;

    struct Badge {
        uint256 id;
        string  name;
        string  metadataURI;  // description or off-chain details
        int256  score;        // positive or negative score contribution
        bool    active;
    }

    // badgeId => Badge
    mapping(uint256 => Badge) public badges;

    // issuer => isApproved
    mapping(address => bool) public isIssuer;

    // user => badgeId => hasBadge
    mapping(address => mapping(uint256 => bool)) public hasBadge;

    // user => reputation score (sum of badge scores)
    mapping(address => int256) public reputationOf;

    uint256 public nextBadgeId;

    event BadgeCreated(uint256 indexed id, string name, int256 score, string metadataURI);
    event BadgeStatusUpdated(uint256 indexed id, bool active);
    event IssuerUpdated(address indexed issuer, bool approved);
    event BadgeAwarded(address indexed user, uint256 indexed badgeId, int256 newReputation);
    event BadgeRevoked(address indexed user, uint256 indexed badgeId, int256 newReputation);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyIssuer() {
        require(isIssuer[msg.sender], "Not issuer");
        _;
    }

    modifier badgeExists(uint256 id) {
        require(bytes(badges[id].name).length != 0, "Badge not found");
        _;
    }

    constructor() {
        owner = msg.sender;
        isIssuer[msg.sender] = true;
        emit IssuerUpdated(msg.sender, true);
    }

    /**
     * @dev Create a new badge type
     */
    function createBadge(
        string calldata name,
        string calldata metadataURI,
        int256 score
    ) external onlyOwner returns (uint256 id) {
        id = nextBadgeId++;
        badges[id] = Badge({
            id: id,
            name: name,
            metadataURI: metadataURI,
            score: score,
            active: true
        });

        emit BadgeCreated(id, name, score, metadataURI);
    }

    /**
     * @dev Activate or deactivate a badge type
     */
    function setBadgeActive(uint256 id, bool active)
        external
        onlyOwner
        badgeExists(id)
    {
        badges[id].active = active;
        emit BadgeStatusUpdated(id, active);
    }

    /**
     * @dev Approve or revoke issuer rights
     */
    function setIssuer(address issuer, bool approved) external onlyOwner {
        isIssuer[issuer] = approved;
        emit IssuerUpdated(issuer, approved);
    }

    /**
     * @dev Award a badge to a user and update reputation
     */
    function awardBadge(address user, uint256 badgeId)
        external
        onlyIssuer
        badgeExists(badgeId)
    {
        require(user != address(0), "Zero address");
        require(!hasBadge[user][badgeId], "Already has badge");
        Badge memory b = badges[badgeId];
        require(b.active, "Badge inactive");

        hasBadge[user][badgeId] = true;
        reputationOf[user] += b.score;

        emit BadgeAwarded(user, badgeId, reputationOf[user]);
    }

    /**
     * @dev Revoke a badge from a user and update reputation
     */
    function revokeBadge(address user, uint256 badgeId)
        external
        onlyIssuer
        badgeExists(badgeId)
    {
        require(hasBadge[user][badgeId], "User lacks badge");
        Badge memory b = badges[badgeId];

        hasBadge[user][badgeId] = false;
        reputationOf[user] -= b.score;

        emit BadgeRevoked(user, badgeId, reputationOf[user]);
    }

    /**
     * @dev Transfer ownership of ChainCrest admin
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        address prev = owner;
        owner = newOwner;
        emit OwnershipTransferred(prev, newOwner);
    }
}

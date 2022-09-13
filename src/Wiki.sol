// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "forge-std/console2.sol";
import "lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
// dependencies for upgradability
import "lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "lib/openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";

contract Wiki is Ownable, Initializable, UUPSUpgradeable {
    using Counters for Counters.Counter;

    /// @notice Counter to keep track of unique article IDs.
    Counters.Counter public articleId;

    /// @notice Counter to keep track of unique version IDs for each article.
    Counters.Counter public versionId;

    /// @notice Mapping to match specific article and version IDs to their editors.
    mapping(string => address) public editors;

    /// @notice Mapping to match specific article and version IDs to their IPFS CIDs.
    mapping(string => string) public links;

    /// @notice Mapping to track the number of versions in each article.
    mapping(uint256 => uint256) public versions;

    /// @notice Struct to return article info
    struct Article {
        uint256 articleId;
        string ipfsHash;
    }

    /// @notice Struct to return version info
    struct Version {
        uint256 articleId;
        uint256 versionId;
        string ipfsHash;
    }

    /// @notice Emits when a new article is created.
    event ArticleCreated(
        uint256 indexed articleId,
        address indexed creator,
        string ipfsHash
    );

    /// @notice Emits when a new version is created for an article.
    event NewVersionCreated(
        uint256 indexed articleId,
        uint256 indexed versionId,
        address indexed editor,
        string ipfsHash
    );

    //------------------- Upgradability Functions -------------------//

    function initialize() public initializer {}

    function authorizeUpgrade(address implementationAddress) public onlyOwner {
        _authorizeUpgrade(implementationAddress);
    }

    function _authorizeUpgrade(address implementationAddress)
        internal
        virtual
        override
        onlyOwner
    {
        _authorizeUpgrade(implementationAddress);
    }

    function upgradeTo(address newImplementation) external virtual override {
        ERC1967Upgrade._upgradeToAndCall(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data)
        external
        payable
        virtual
        override
    {
        ERC1967Upgrade._upgradeToAndCall(newImplementation, data, false);
    }

    //------------------- Mutative Functions -------------------//

    /**
     * @notice Creates a new article.
     * @param ipfsHash The unique IPFS CID referencing the contents of the article
     * @return createdArticleId The article ID of the newly created article.
     */
    function createArticle(string calldata ipfsHash)
        public
        returns (uint256 createdArticleId)
    {
        bytes memory tempIpfsHash = bytes(ipfsHash);
        require(
            tempIpfsHash.length > 0,
            "IPFS hash cannot be an empty string."
        );
        uint256 currentArticleId = articleId.current();
        uint256 currentVersionId = versionId.current();
        string memory currentArticleIdStr = Strings.toString(currentArticleId);
        string memory currentVersionIdStr = Strings.toString(currentVersionId);

        string memory identifier = string.concat(
            currentArticleIdStr,
            "x",
            currentVersionIdStr
        );

        editors[identifier] = msg.sender;
        links[identifier] = ipfsHash;

        articleId.increment();

        emit ArticleCreated(currentArticleId, msg.sender, ipfsHash);
        return currentArticleId;
    }

    /**
     * @notice Creates a new version of an existing article.
     * @dev Throws if the article referenced in params has not been created yet.
     * @param existingArticleId The ID of the article that a new version will be added to.
     * @param ipfsHash The unique IPFS CID referencing the contents of the article
     */

    function addVersion(uint256 existingArticleId, string calldata ipfsHash)
        public
        returns (string memory latestIdentifier)
    {
        uint256 maxArticleId = articleId.current();
        require(
            existingArticleId < maxArticleId,
            "This article does not exist."
        );
        uint256 currentVersionId = versions[existingArticleId];
        uint256 newVersionId = currentVersionId + 1;

        string memory existingArticleIdStr = Strings.toString(
            existingArticleId
        );
        string memory newVersionIdStr = Strings.toString(newVersionId);

        string memory identifier = string.concat(
            existingArticleIdStr,
            "x",
            newVersionIdStr
        );

        editors[identifier] = msg.sender;
        links[identifier] = ipfsHash;
        versions[existingArticleId] = newVersionId;

        emit NewVersionCreated(
            existingArticleId,
            newVersionId,
            msg.sender,
            ipfsHash
        );
        return identifier;
    }

    // ------------------- View Functions ------------------- //

    function getAllLatestArticles() public view returns (string[] memory) {
        uint256 maxArticleId = articleId.current();
        uint256 totalNumArticles = maxArticleId + 1;
        string[] memory returnArray = new string[](totalNumArticles);

        for (uint256 i = 0; i < maxArticleId; i++) {
            uint256 latestVersionId = versions[i];
            string memory articleIdStr = Strings.toString(i);
            string memory versionIdStr = Strings.toString(latestVersionId);
            string memory identifier = string.concat(
                articleIdStr,
                "x",
                versionIdStr
            );
            string memory latestLink = links[identifier];
            returnArray[i] = latestLink;
        }
        return returnArray;
    }

    // ------------------- User View Functions ------------------- //

    function getArticlesCreatedByAddress(address user)
        public
        view
        returns (Article[] memory)
    {
        uint256 numArticles = articleId.current();
        uint256 userArticles = 0;

        for (uint256 i = 0; i < numArticles; i++) {
            string memory currentArticleIdStr = Strings.toString(i);
            string memory identifier = string.concat(
                currentArticleIdStr,
                "x",
                "0"
            );

            if (editors[identifier] == user) {
                userArticles++;
                console2.log("identifiers", identifier);
            }
        }

        Article[] memory returnArray = new Article[](userArticles);

        for (uint256 i = 0; i < numArticles; i++) {
            string memory currentArticleIdStr = Strings.toString(i);
            string memory identifier = string.concat(
                currentArticleIdStr,
                "x",
                "0"
            );
            if (editors[identifier] == user) {
                Article memory currentArticle;
                currentArticle.articleId = i;
                currentArticle.ipfsHash = links[identifier];
                returnArray[i] = currentArticle;
            }
        }

        return returnArray;
    }

    function getVersionCreatedByAddress(address user)
        public
        view
        returns (Version[] memory)
    {
        // iterate through all articles and versions to find editor = user
    }
}

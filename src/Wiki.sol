// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import {Counters} from "lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {console2} from "forge-std/console2.sol";

contract Wiki {
    using Counters for Counters.Counter;

    /// @notice Counter to keep track of unique article IDs.
    Counters.Counter public articleId;

    /// @notice Counter to keep track of unique version IDs for each article.
    Counters.Counter public versionId;

    /// @notice Mapping to match specific article and version IDs to their editors.
    mapping(string => address) editors;

    /// @notice Mapping to match specific article and version IDs to their IPFS CIDs.
    mapping(string => string) links;

    /// @notice Mapping to track the number of versions in each article.
    mapping(uint256 => uint256) versions;

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

    /**
     * @notice Creates a new article.
     * @param ipfsHash The unique IPFS CID referencing the contents of the article
     * @return createdArticleId The article ID of the newly created article.
     */
    function createArticle(string calldata ipfsHash)
        public
        returns (uint256 createdArticleId)
    {
        uint256 currentArticleId = articleId.current();
        uint256 currentVersionId = versionId.current();
        string memory currentArticleIdStr = Strings.toString(currentArticleId);
        string memory currentVersionIdStr = Strings.toString(currentVersionId);

        string memory identifier = string.concat(
            currentArticleIdStr,
            "x",
            currentVersionIdStr
        );

        console2.log("create identifier", identifier);

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
    {
        uint256 maxArticleId = articleId.current();
        require(
            existingArticleId < maxArticleId,
            "This article does not exist"
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

        console2.log("new version identifier", identifier);
        emit NewVersionCreated(
            existingArticleId,
            newVersionId,
            msg.sender,
            ipfsHash
        );
    }
}

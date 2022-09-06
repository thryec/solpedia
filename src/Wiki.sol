// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import {Counters} from "lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {console} from "forge-std/console.sol";

contract Wiki {
    using Counters for Counters.Counter;

    Counters.Counter public articleId;
    Counters.Counter public versionId;

    mapping(string => address) editors;
    mapping(string => string) links;
    mapping(uint256 => uint256) versions;

    event ArticleCreated(
        uint256 indexed articleId,
        address indexed creator,
        string ipfsHash
    );

    event NewVersionCreated(
        uint256 indexed articleId,
        uint256 indexed versionId,
        address indexed editor,
        string ipfsHash
    );

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

        console.log("create identifier", identifier);

        editors[identifier] = msg.sender;
        links[identifier] = ipfsHash;

        articleId.increment();

        emit ArticleCreated(currentArticleId, msg.sender, ipfsHash);
        return currentArticleId;
    }

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

        console.log("new version identifier", identifier);
        emit NewVersionCreated(
            existingArticleId,
            newVersionId,
            msg.sender,
            ipfsHash
        );
    }
}

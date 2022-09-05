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
    mapping(uint256 => uint256) articleIdToVersionNum;

    event ArticleCreated(
        uint256 indexed articleId,
        address indexed creator,
        string ipfsHash
    );

    event ArticleEdited(
        uint256 indexed articleId,
        uint256 indexed versionId,
        address indexed editor,
        string ipfsHash
    );

    function createArticle(string calldata ipfsHash) public {
        uint256 currentArticleId = articleId.current();
        uint256 currentVersionId = versionId.current();
        console.log(
            "article and version ids",
            currentArticleId,
            currentVersionId
        );
        string memory currentArticleIdStr = Strings.toString(currentArticleId);
        string memory currentVersionIdStr = Strings.toString(currentVersionId);

        string memory identifier = string.concat(
            currentArticleIdStr,
            "x",
            currentVersionIdStr
        );

        console.log("identifier", identifier);

        editors[identifier] = msg.sender;
        links[identifier] = ipfsHash;

        articleId.increment();

        emit ArticleCreated(currentArticleId, msg.sender, ipfsHash);
    }

    function addVersion(uint256 currentArticleId, string calldata ipfsHash)
        public
    {}
}

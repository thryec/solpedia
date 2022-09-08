// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../src/Wiki.sol";
import "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {console2} from "forge-std/console2.sol";

abstract contract StateZero is Test {
    Wiki internal wiki;
    address alice;
    address bob;
    address carol;
    address root = address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);

    string ipfsHash = "bafybohew2j2wbn3mzl7dakkoklstoas4jq3rj7wgiv6mmtvk7v7a";
    string secondVersionHash =
        "bafybohew2j2wbn3mzl7dakkoklstoas4jq3rj7wgiv6mmtvk7v7b";
    string thirdVersionHash =
        "bafybohew2j2wbn3mzl7dakkoklstoas4jq3rj7wgiv6mmtvk7v7c";

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

    function setUp() public virtual {
        wiki = new Wiki();
        alice = address(0x1);
        bob = address(0x2);
        carol = address(0x3);

        vm.label(alice, "alice");
        vm.label(bob, "bob");
        vm.label(carol, "carol");
    }
}

contract StateZeroTest is StateZero {
    function testCreateArticle() public {
        uint256 articleId = wiki.createArticle(ipfsHash);
        assertEq(articleId, 0);
    }

    function testCreateArticleStoresCorrectEditor() public {
        vm.prank(alice);
        uint256 articleId = wiki.createArticle(ipfsHash);
        string memory articleIdStr = Strings.toString(articleId);
        string memory identifier = string.concat(articleIdStr, "x", "0");
        address editor = wiki.editors(identifier);
        assertEq(editor, alice);
    }

    function testCreateArticleStoresCorrectLink() public {
        uint256 articleId = wiki.createArticle(ipfsHash);
        string memory articleIdStr = Strings.toString(articleId);
        string memory identifier = string.concat(articleIdStr, "x", "0");
        string memory link = wiki.links(identifier);
        assertEq(link, ipfsHash);
    }

    function testCreateArticleDoesntAllowEmptyHash() public {
        string memory emptyIpfs = "";
        vm.expectRevert(bytes("IPFS hash cannot be an empty string."));
        wiki.createArticle(emptyIpfs);
    }

    // function testCreateArticleEmitsEvent() public {
    //     vm.expectEmit(true, true, true);
    //     emit ArticleCreated(0, alice, ipfsHash);
    //     vm.prank(alice);
    //     wiki.createArticle(ipfsHash);
    // }

    function testAddVersionReverts() public {
        vm.expectRevert(bytes("This article does not exist."));
        uint256 nonexistentArticleId = 5;
        wiki.addVersion(nonexistentArticleId, secondVersionHash);
    }

    function testGetArticlesByAddressReturnsEmptyArray() public {
        Wiki.Article[] memory result = wiki.getArticlesCreatedByAddress(root);
        assertEq(result.length, 0);
    }
}

abstract contract StateArticleCreated is StateZero {
    uint256 articleId;

    function setUp() public virtual override {
        super.setUp();

        articleId = wiki.createArticle(ipfsHash);
    }
}

contract StateArticleCreatedTest is StateArticleCreated {
    function testAddVersion() public {
        string memory newIdentifier = wiki.addVersion(
            articleId,
            secondVersionHash
        );
        string memory articleIdStr = Strings.toString(articleId);
        string memory identifier = string.concat(articleIdStr, "x", "1");
        assertEq(identifier, newIdentifier);
    }

    function testAddVersionStoresCorrectEditor() public {
        vm.prank(bob);
        wiki.addVersion(articleId, secondVersionHash);
        string memory articleIdStr = Strings.toString(articleId);
        string memory identifier = string.concat(articleIdStr, "x", "1");
        address editor = wiki.editors(identifier);
        assertEq(editor, bob);
    }

    function testAddVersionStoresCorrectLink() public {
        wiki.addVersion(articleId, secondVersionHash);
        string memory articleIdStr = Strings.toString(articleId);
        string memory identifier = string.concat(articleIdStr, "x", "1");
        string memory link = wiki.links(identifier);
        assertEq(link, secondVersionHash);
    }

    // function testAddVersionEmitsEvent() public {
    //     vm.expectEmit(true, true, true, true);
    //     emit NewVersionCreated(0, 1, bob, secondVersionHash);
    //     vm.prank(bob);
    //     wiki.addVersion(articleId, secondVersionHash);
    // }

    function testGetArticlesByCreatorReturnsSingleElementArray() public {
        Wiki.Article[] memory result = wiki.getArticlesCreatedByAddress(root);
        assertEq(result.length, 1);
        assertEq(result[0].articleId, articleId);
        assertEq(result[0].ipfsHash, ipfsHash);
    }

    function testGetArticlesByRandomAddressReturnsEmptyArray() public {
        Wiki.Article[] memory result = wiki.getArticlesCreatedByAddress(alice);
        assertEq(result.length, 0);
    }
}

abstract contract StateArticleAndNewVersionCreated is StateZero {
    uint256 articleId;

    function setUp() public virtual override {
        super.setUp();

        articleId = wiki.createArticle(ipfsHash);
        wiki.addVersion(articleId, ipfsHash);
    }
}

contract StateArticleAndNewVersionCreatedTest is
    StateArticleAndNewVersionCreated
{
    function testAddVersion() public {
        string memory newIdentifier = wiki.addVersion(
            articleId,
            thirdVersionHash
        );
        string memory articleIdStr = Strings.toString(articleId);
        string memory identifier = string.concat(articleIdStr, "x", "2");
        assertEq(newIdentifier, identifier);
    }

    function testAddVersionStoresCorrectEditor() public {
        vm.prank(carol);
        wiki.addVersion(articleId, thirdVersionHash);
        string memory articleIdStr = Strings.toString(articleId);
        string memory identifier = string.concat(articleIdStr, "x", "2");
        address editor = wiki.editors(identifier);
        assertEq(editor, carol);
    }

    function testAddVersionStoresCorrectLink() public {
        wiki.addVersion(articleId, thirdVersionHash);
        string memory articleIdStr = Strings.toString(articleId);
        string memory identifier = string.concat(articleIdStr, "x", "2");
        string memory link = wiki.links(identifier);
        assertEq(link, thirdVersionHash);
    }
}

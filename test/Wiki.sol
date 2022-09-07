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

    string ipfsHash = "bafybohew2j2wbn3mzl7dakkoklstoas4jq3rj7wgiv6mmtvk7v7a";
    string secondVersionHash =
        "bafybohew2j2wbn3mzl7dakkoklstoas4jq3rj7wgiv6mmtvk7v7b";
    string thirdVersionHash =
        "bafybohew2j2wbn3mzl7dakkoklstoas4jq3rj7wgiv6mmtvk7v7c";

    function setUp() public virtual {
        wiki = new Wiki();
        alice = address(0x1);
        bob = address(0x2);

        vm.label(alice, "alice");
        vm.label(bob, "bob");
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

    // function testCreateArticleEmitsEvent() public {
    //     vm.expectEmit(0, alice, ipfsHash);
    //     vm.prank(alice);
    //     wiki.createArticle(ipfsHash);
    // }

    function testAddVersionReverts() public {
        vm.expectRevert(bytes("This article does not exist."));
        uint256 nonexistentArticleId = 5;
        wiki.addVersion(nonexistentArticleId, secondVersionHash);
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

    // function testAddEmitsEvent() public {
    //     vm.expectEmit(0, 1, bob, secondVersionHash);
    //     vm.prank(bob);
    //     wiki.addVersion(articleId, secondVersionHash);
    // }
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

    function testAddVersionStoresCorrectEditor() public {}

    function testAddVersionStoresCorrectLink() public {}
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../src/Wiki.sol";
import "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {console2} from "forge-std/console2.sol";

// contract ContractTest is Test {
//     Wiki internal wiki;
//     function setUp() public {
//         wiki = new Wiki();
//     }
//     function testCreateArticle() public {
//         uint256 articleId = wiki.createArticle(ipfsHash1);
//         console2.log("new article id", articleId);
//         wiki.addVersion(articleId, ipfsHash1);
//     }
// }

abstract contract StateZero is Test {
    Wiki internal wiki;
    address alice;

    function setUp() public virtual {
        wiki = new Wiki();
        alice = address(0x1);
        vm.label(alice, "alice");
    }
}

contract StateZeroTest is StateZero {
    string ipfsHash = "bafybohew2j2wbn3mzl7dakkoklstoas4jq3rj7wgiv6mmtvk7v7a";

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

    function testAddVersionReverts() public {
        vm.expectRevert(bytes("This article does not exist."));
        uint256 nonexistentArticleId = 5;
        wiki.addVersion(nonexistentArticleId, ipfsHash);
    }
}

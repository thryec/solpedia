// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../src/Wiki.sol";
import "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";

contract ContractTest is Test {
    Wiki internal wiki;

    string ipfsHash1 = "bafybohew2j2wbn3mzl7dakkoklstoas4jq3rj7wgiv6mmtvk7v7a";

    function setUp() public {
        wiki = new Wiki();
    }

    function testCreateArticle() public {
        uint256 articleId = wiki.createArticle(ipfsHash1);
        console.log("new article id", articleId);
        wiki.addVersion(articleId, ipfsHash1);
    }
}

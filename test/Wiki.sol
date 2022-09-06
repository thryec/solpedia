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

    function setUp() public virtual {
        wiki = new Wiki();
    }
}

contract StateZeroTest is StateZero {
    string ipfsHash1 = "bafybohew2j2wbn3mzl7dakkoklstoas4jq3rj7wgiv6mmtvk7v7a";

    function testCreateArticle() public {
        uint256 articleId = wiki.createArticle(ipfsHash1);
        console2.log("new article id", articleId);
        assertEq(articleId, 0);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Counters} from "lib/openzeppelin-contracts/contracts/utils/Counters.sol";

contract Wiki {
    using Counters for Counters.Counter;

    Counters.Counter public articleId;
    Counters.Counter public versionId;

    //article struct
    struct article {
        uint256 articleId
        uint256 versionId
        //address lastEditor 
    }
    
    // articles/hashes in universe
    mapping (string ipfsHash => boolean) public articles;

    mapping (uint256 articleId => mapping(uint256 versionId => string ipfsHash)) public versionTree;

    //map user actions to wallet addresses - who did what
    mapping (uint256 articleId => address user) public authors;
    mapping (uint256 versionId => address user) public editors;


    event Created( address indexed from, uint256 indexed articleId, uint256 indexed versionId, string ipfsHash);
    event Updated( address indexed from, uint256 indexed articleId, uint256 indexed versionId, string ipfsHash);

    function create(string calldata ipfsHash) external {
        // require(ipfsHash should be unique);
        
        require(articles(ipfsHash) == false);         // article hash should not exist
        
        uint256 newArticleId = articleId.current();   // starts frm 0
        uint256 newVersionId = versionId.current();

        versionTree(newArticleId)() = 

    }

    function update() public {
        require(articles(ipfsHash) == true); //article hash should exist

    }

    //function moduleCall() {} // extensibility
}


// id -> each article has a unique ID
// versionIndex -> version iteration
//
// Actions -> {create,modify}

// https://docs.openzeppelin.com/contracts/4.x/utilities#base64
// for ipfs hash handling
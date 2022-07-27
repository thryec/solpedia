// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Counters} from "lib/openzeppelin-contracts/contracts/utils/Counters.sol";

contract Wiki {
    using Counters for Counters.Counter;

    Counters.Counter public id;
    Counters.Counter public index;

    mapping (uint256 id => mapping(uint256 index => string link));
    mapping (uint256 id => uint256 numEntries);

    event Created( address indexed from, uint256 indexed id, uint256 indexed index, string article);

    event Updated( address indexed from, uint256 indexed id, uint256 indexed index, string article);

    function create(string calldata link) public {
        //require();


    }

    function read() public view {}

    function update() public {}

    //function moduleCall() {} // extensibility
}

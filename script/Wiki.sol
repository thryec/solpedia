// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../src/Wiki.sol";
import "forge-std/Script.sol";

contract ContractScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        new Wiki();
        vm.stopBroadcast();
    }
}

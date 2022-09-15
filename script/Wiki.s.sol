// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "forge-std/Script.sol";
import "../src/Wiki.sol";

contract WikiScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        new Wiki();

        vm.stopBroadcast();
    }
}

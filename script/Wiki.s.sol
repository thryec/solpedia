// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "forge-std/Script.sol";
import "../src/Wiki.sol";
import "../src/WikiProxy.sol";
import "forge-std/console2.sol";

contract WikiScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Wiki wiki = new Wiki();
        WikiProxy proxy = new WikiProxy();

        console2.log("wiki address", address(wiki));
        console2.log("proxy address", address(proxy));

        vm.stopBroadcast();
    }
}

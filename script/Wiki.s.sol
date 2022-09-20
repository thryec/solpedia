// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "forge-std/Script.sol";
import "../src/Wiki.sol";
import "../src/WikiProxy.sol";
import "forge-std/console2.sol";

contract WikiScript is Script {
    address admin;
    bytes data = "";

    function setUp() public {
        admin = address(0x1);
        vm.label(admin, "admin");
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Wiki wiki = new Wiki();
        WikiProxy proxy = new WikiProxy();

        console2.log("wiki deployed to: ", address(wiki));
        console2.log("proxy deployed to", address(proxy));

        proxy.setType("uups");
        address proxyAddress = proxy.deployErc1967Proxy(address(wiki), data);
        console2.log("proxy address", proxyAddress);
        // address implementationAddr = proxyAddress.

        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "forge-std/Script.sol";
import "../src/Wiki.sol";
import "../src/Wiki2.sol";
import "../src/WikiProxy.sol";
import "forge-std/console2.sol";
import {TransparentUpgradeableProxy} from "openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";

contract WikiScript is Script {
    TransparentUpgradeableProxy public uups;
    address admin;
    address owner;
    address root;
    bytes data = "";

    function setUp() public {
        admin = address(0x1);
        owner = address(0x3eb9c5B92Cb655f2769b5718D33f72E23B807D24);
        root = address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);
        vm.label(admin, "admin");
    }

    function run() public {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // vm.startBroadcast(deployerPrivateKey);

        Wiki wiki = new Wiki();
        WikiProxy proxyManager = new WikiProxy();
        vm.label(address(wiki), "wiki address");
        vm.label(address(proxyManager), "proxy manager");

        console2.log("wiki deployed to: ", address(wiki));
        console2.log("proxy deployed to:", address(proxyManager));

        uups = proxyManager.deployUupsProxy(address(wiki), admin, data);
        console2.log("uups address", address(uups));

        vm.startPrank(admin);
        console2.log("uups admin", uups.admin());
        address currentImplementation = uups.implementation();
        console2.log("current implementation", currentImplementation);
        vm.stopPrank();

        Wiki2 wiki2 = new Wiki2();
        vm.label(address(wiki2), "wiki2 address");
        console2.log("wiki2 address", address(wiki2));

        proxyManager.upgrade(address(wiki2), admin, root);

        vm.startPrank(admin);
        address newImplementation = uups.implementation();
        console2.log("new implementation", newImplementation);
        vm.stopPrank();

        // vm.stopBroadcast();
    }
}

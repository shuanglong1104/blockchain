// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {MyToken} from "../src/MyToken.sol";

contract MyTokenScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        MyToken token = new MyToken("token66", "token66");

        console.log("token:", address(token));
        console.log("name:", token.name());
        console.log("symbol:", token.symbol());

        require(token.totalSupply()==1e10*1e18,"bad totalSupply");

    }
}


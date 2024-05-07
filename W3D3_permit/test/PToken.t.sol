// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {PToken} from "../src/pToken.sol";

contract PTokenTest is Test {
  PToken public pToken;

  function setUp() public {
    pToken = new PToken("pToken", "PTK");
  }

  function test_Mint() public {
    assertEq(pToken.totalSupply(), 10 ** 18);
  }
}

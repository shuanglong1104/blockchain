// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {MyWallet} from "../src/MyWallet.sol";

contract MyWalletTest is Test {
  MyWallet public wallet;
  address public owner = address(0x123);
  address public newOwner = address(0x456);

  function setUp() public {
    vm.prank(owner);
    wallet = new MyWallet("My Wallet");
  }

  function testTransferOwnership() public {
    assertEq(wallet.getOwner(), owner, "Owner not set");
    vm.prank(newOwner);
    vm.expectRevert("Not authorized");
    wallet.transferOwernship(newOwner);
    vm.startPrank(owner);
    vm.expectRevert("New owner is the zero address");
    wallet.transferOwernship(address(0));
    vm.expectRevert("New owner is the same as the old owner");
    wallet.transferOwernship(owner);

    //set new owner
    wallet.transferOwernship(newOwner);
    assertEq(wallet.getOwner(), newOwner, "Owner not transferred");
    vm.stopPrank();
  }
}

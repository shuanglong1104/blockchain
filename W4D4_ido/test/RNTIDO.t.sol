// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {RNTIDO} from "../src/RNTIDO.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyToken is ERC20 {
  constructor() ERC20("RNT", "RNT") {}

  function mint(address to, uint256 amount) public {
    _mint(to, amount);
  }
}

contract RNTIDOTest is Test {
  RNTIDO rntido;
  MyToken rnt;
  uint256 totalSold = 0;
  uint256 totalRaised = 0;
  address testuser = address(0x123);
  address owner = address(0x456);

  function setUp() public {
    rnt = new MyToken();
    vm.prank(owner);
    rntido = new RNTIDO(IERC20(address(rnt)));
    rnt.mint(address(rntido), 1e24);

    vm.deal(testuser, 100 ether);
    console.log("testuser balance: ", testuser.balance);
    console.log("RNT deployed at: ", address(rnt));
    console.log("RNTIDO deployed at: ", address(rntido));
  }

  function testPresale() public {
    vm.startPrank(testuser);

    uint256 amountToBuy = 100000;
    uint256 payment = amountToBuy * rntido.PRICE();
    // console.log("Payment: ", payment);
    rntido.presaleRNT{value: payment}(amountToBuy);

    totalSold = totalSold + amountToBuy;
    totalRaised = totalRaised + payment;
    assertEq(rntido.totalSold(), totalSold, "Invalid totalSole");
    assertEq(rntido.totalRaised(), totalRaised, "Invalid totalRaised");

    vm.stopPrank();
  }

  function testClaimTokenSuccess() public {
    // ensure presale reach softcap
    for (uint i = 0; i < 25; i++) {
      testPresale();
    }
    console.log("Total sold: ", rntido.totalSold());
    console.log("Total TOTAL_SUPPLY: ", rntido.TOTAL_SUPPLY());

    vm.warp(block.timestamp + 15 days); //move time to after END_AT

    vm.startPrank(testuser);
    rntido.claim();
    assertEq(rnt.balanceOf(testuser), totalSold, "Invalid RNT balance after claim");
    vm.stopPrank();
  }

  function testRefundNotReachSoftcap() public {
    testPresale();
    vm.warp(block.timestamp + 15 days); //move time to after END_AT

    vm.startPrank(testuser);
    rntido.refund();
    assertEq(testuser.balance, 100 ether, "testuser should get refund");
    vm.stopPrank();
  }

  function testwithdraw() public {
    // ensure presale reach softcap
    for (uint i = 0; i < 25; i++) {
      testPresale();
    }

    vm.warp(block.timestamp + 15 days); //move time to after END_AT

    vm.prank(testuser);
    vm.expectRevert("only owner can operate");
    rntido.withdraw();

    vm.prank(owner);
    rntido.withdraw();
    assertEq(owner.balance, totalRaised, "testuser should withdraw all raised money");
  }
}

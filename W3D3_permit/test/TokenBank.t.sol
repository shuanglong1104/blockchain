// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {TokenBank} from "../src/TokenBank.sol";
import {PToken} from "../src/PToken.sol";

contract TokenBankTest is Test {
  TokenBank public tokenBank;

  PToken public pToken;

  function setUp() public {
    address owner = makeAddr("owner");
    vm.prank(owner);
    pToken = new PToken("pToken", "PTK");
    tokenBank = new TokenBank(address(pToken));
  }

  function test_permitDeposit() public {
    //***********************离线签名开始***********************
    (address owner, uint256 ownerKey) = makeAddrAndKey("owner");
    emit log_address(owner);
    emit log_uint(ownerKey);
    address spender = address(tokenBank);
    uint256 value = 100;
    uint256 deadline = block.timestamp + 1 days;
    uint256 nonce = pToken.nonces(owner);

    bytes32 PERMIT_TYPEHASH = keccak256(
      "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
    );

    bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline));
    bytes32 DOMAIN_SEPARATOR = pToken.DOMAIN_SEPARATOR();

    //_hashTypedDataV4是由\x19\x01，域分隔符（DOMAIN_SEPARATOR）和类型数据的哈希组合在一起，然后进行keccak256哈希得到的
    bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));

    //签名获得v, r, s
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerKey, digest);
    //***********************离线签名结束***********************

    vm.startPrank(owner);
    //验证签名
    tokenBank.permitDeposit(owner, spender, value, deadline, v, r, s);
    //验证owner的余额
    assertEq(tokenBank.balances(owner), value);
    emit log_uint(tokenBank.balances(owner));

    vm.expectRevert();
    tokenBank.permitDeposit(owner, spender, value + 1, deadline, v, r, s);
    vm.expectRevert();
    tokenBank.permitDeposit(owner, spender, value, deadline - 1, v, r, s);

    vm.stopPrank();
  }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {PToken} from "../src/PToken.sol";
import {MyNFT} from "../src/MyNFT.sol";
import {NFTMarket} from "../src/NFTMarket.sol";

contract NFTMarketTest is Test {
  NFTMarket public nftMarket;

  PToken public pToken;
  MyNFT public myNFT;

  function setUp() public {
    //买方
    address buyer = makeAddr("buyer");
    vm.prank(buyer);
    pToken = new PToken("pToken", "PTK");

    //卖方
    address seller = makeAddr("seller");
    vm.prank(seller);
    myNFT = new MyNFT("MyNFT", "MNFT");

    //NFT市场
    nftMarket = new NFTMarket(address(pToken), address(myNFT));

    vm.stopPrank();
  }

  function test_permitBuy() public {
    //***********************离线签名开始***********************
    (address seller, uint256 sellerKey) = makeAddrAndKey("seller");
    //seller mint nft and list
    vm.startPrank(seller);
    uint256 tokenId = myNFT.mint(seller, "ipfs://QmdHQz8WnJugJ3tt7Yk2Zh751t1k7LD1etWgfW66QXhN4z");
    myNFT.approve(address(nftMarket), tokenId);
    nftMarket.list(tokenId, 100);

    //检查NFT市场
    assertEq(nftMarket.tokenSeller(tokenId), seller);
    assertEq(nftMarket.tokenIdPrice(tokenId), 100);
    vm.stopPrank();

    /**
     * 离线签名
     */
    uint256 deadline = block.timestamp + 1 days;
    address buyer = makeAddr("buyer");
    bytes32 khash = keccak256(abi.encodePacked(buyer, tokenId, deadline));
    bytes32 digest = keccak256(abi.encodePacked(khash));
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(sellerKey, digest);

    //购买
    vm.startPrank(buyer);
    pToken.approve(address(nftMarket), 100);
    nftMarket.permitBuy(buyer, tokenId, deadline, v, r, s);
    //检查已授权购买
    assertEq(myNFT.ownerOf(tokenId), buyer);
    vm.stopPrank();

    //检查未授权购买
    address buyer2 = makeAddr("buyer2_not_permit");
    vm.startPrank(buyer2);
    pToken.approve(address(nftMarket), 100);
    vm.expectRevert();
    nftMarket.permitBuy(buyer2, tokenId, deadline, v, r, s);
    vm.stopPrank();
  }
}

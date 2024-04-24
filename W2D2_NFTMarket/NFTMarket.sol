// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
编写一个简单的 NFT市场合约，使用自己的发行的 Token 来买卖 NFT， 函数的方法有：

list() : 实现上架功能，NFT 持有者可以设定一个价格（需要多少个 Token 购买该 NFT）并上架 NFT 到 NFT 市场。
buyNFT() : 实现购买 NFT 功能，用户转入所定价的 token 数量，获得对应的 NFT。
请在回答贴出你的代码或者 github 链接。
*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarket is IERC721Receiver{
    mapping (uint=>uint) public tokenIdPrice;
    mapping (uint=>address) public tokenSeller;
    address public immutable token;
    address public immutable nftToken;

    constructor(address _token,address _nftToken){
        token = _token;
        nftToken = _nftToken;
    }

    //合约通过实现 IERC721Receiver 接口，确保能够正确接收和处理 NFT
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4){
        return this.onERC721Received.selector;
    }

    //NFT持有者可以将其NFT上架，并设定一个价格
    function list(uint tokenID,uint amount) public {
        IERC721(nftToken).safeTransferFrom(msg.sender,address(this),tokenID,"");
        tokenIdPrice[tokenID] = amount;
        tokenSeller[tokenID] = msg.sender;
    }

    //用户可以购买上架的 NFT，并支付相应的 ERC20 代币
    function buyNFT(uint tokenID,uint amount) public {
        require(amount >= tokenIdPrice[tokenID],"low price");
        require(IERC721(nftToken).ownerOf(tokenID)==address(this),"already sold");

        IERC20(token).transferFrom(msg.sender,tokenSeller[tokenID],amount);
        IERC721(nftToken).transferFrom(address(this),msg.sender,tokenID);
    }







}
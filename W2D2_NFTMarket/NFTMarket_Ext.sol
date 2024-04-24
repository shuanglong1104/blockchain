// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
扩展挑战Token 购买 NFT 合约，能够使用ERC20扩展中的回调函数来购买某个 NFT ID。
*/

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./MyERC20.sol";

interface ITokenRecipient {
    function tokensReceived(address sender, uint256 amount,uint tokenID) external returns (bool);
}

contract NFTMarket is IERC721Receiver,ITokenRecipient{
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

    function tokensReceived(address sender, uint256 amount,uint tokenID) external override returns (bool){
        buyNFT(tokenID,amount);
        
        return true;
    }

}
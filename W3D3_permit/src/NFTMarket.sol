// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
添加功能 permitBuy() 实现只有离线授权的白名单地址才可以购买 NFT （用自己的名称发行 NFT，再上架） 。
白名单具体实现逻辑为：项目方给白名单地址签名，白名单用户拿到签名信息后，传给 permitBuy() 函数，
在permitBuy()中判断时候是经过许可的白名单用户，如果是，才可以进行后续购买，否则 revert 。
*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarket is IERC721Receiver {
  mapping(uint => uint) public tokenIdPrice;
  mapping(uint => address) public tokenSeller;
  address public immutable token;
  address public immutable nftToken;

  constructor(address _token, address _nftToken) {
    token = _token;
    nftToken = _nftToken;
  }

  //合约通过实现 IERC721Receiver 接口，确保能够正确接收和处理 NFT
  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external override returns (bytes4) {
    return this.onERC721Received.selector;
  }

  //NFT持有者可以将其NFT上架，并设定一个价格
  function list(uint tokenID, uint amount) public {
    IERC721(nftToken).safeTransferFrom(msg.sender, address(this), tokenID, "");
    tokenIdPrice[tokenID] = amount;
    tokenSeller[tokenID] = msg.sender;
  }

  //用户可以购买上架的 NFT，并支付相应的 ERC20 代币
  function buyNFT(uint tokenID, uint amount) public {
    require(amount >= tokenIdPrice[tokenID], "low price");
    require(IERC721(nftToken).ownerOf(tokenID) == address(this), "already sold");
    IERC20(token).transferFrom(msg.sender, tokenSeller[tokenID], amount);
    IERC721(nftToken).transferFrom(address(this), msg.sender, tokenID);
  }

  function permitBuy(address _user, uint _tokenId, uint deadline, uint8 _v, bytes32 _r, bytes32 _s) external {
    require(block.timestamp <= deadline, "time expired");

    // abi.encodePacked() 用于将多个参数打包成一个字节数组
    // keccak256() 用于计算字节数组的 keccak256 哈希值
    // ecrecover() 用于从签名中恢复签名者的地址
    bytes32 khash = keccak256(abi.encodePacked(_user, _tokenId, deadline));
    bytes32 digest = keccak256(abi.encodePacked(khash));
    address signer = ecrecover(digest, _v, _r, _s);

    // 验证白名单签名
    require(signer == tokenSeller[_tokenId], "invalid signer");
    //购买NFT
    buyNFT(_tokenId, tokenIdPrice[_tokenId]);
  }
}

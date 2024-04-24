// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
用 ERC721 标准发行一个自己 NFT 合约，并用图片铸造几个 NFT ， 请把图片和 Meta Json数据上传到去中心的存储服务中，请贴出在 OpenSea 的 NFT 链接。
*/

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyERC721 is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721(unicode"MyNFT", "MNFT") {}

    // https://testnets.opensea.io/zh-CN/assets/sepolia/0x21894f2678e528c3a40d774621775b11cd098602/0
    // Qmb4SpeWYF4RYiPJcZDHdmqdr73HCRfDKnfWCfZCcDCYYg

    // ipfs://QmdHQz8WnJugJ3tt7Yk2Zh751t1k7LD1etWgfW66QXhN4z
    function mint(address to, string memory tokenURI) public returns (uint256){
        uint256 newItemId = _tokenIds.current();
        _mint(to, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();
        return newItemId;
    }
}
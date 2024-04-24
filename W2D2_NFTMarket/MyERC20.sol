// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
扩展 ERC20 合约，使其具备在转账的时候，如果目标地址是合约的话，调用目标地址的 tokensReceived() 方法.
*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface TokenRecipient {
    function tokensReceived(address sender, uint256 amount) external returns (bool);
}

contract MyERC20 is ERC20{

    constructor() ERC20("MyERC20","MERC20"){
        _mint(msg.sender,2100 * 10 ** 18);
    }

    function transferFromWithCallBack(address from,address to, uint256 value) public returns (bool){
        transferFrom(from, to, value);

        // 如果目标地址是合约，调用 tokensReceived 方法
        if (to.code.length > 0){
            bool res = TokenRecipient(to).tokensReceived(from,value);
            require(res,"transfer fail");
        }

        return true;
    }

    function transferWithCallBack(address to, uint256 value) public returns (bool){
        transfer(to, value);

        // 如果目标地址是合约，调用 tokensReceived 方法
        if (to.code.length > 0){
            bool res = TokenRecipient(to).tokensReceived(msg.sender,value);
            require(res,"transfer fail");
        }

        return true;
    }

}
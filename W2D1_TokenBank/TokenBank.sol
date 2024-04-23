// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
编写一个 TokenBank 合约，可以将自己的 Token 存入到 TokenBank， 和从 TokenBank 取出。

TokenBank 有两个方法：

deposit() : 需要记录每个地址的存入数量；
withdraw（）: 用户可以提取自己的之前存入的 token。
*/

import "./BaseERC20.sol";
contract TokenBank {
    mapping(address => uint256) balances;
    BaseERC20 public myToken;

    event Deposit(address indexed _account,uint256 _amount);
    event Withdraw(address indexed _account,uint256 _amount);

    constructor (address _addr) {
        myToken =  BaseERC20(_addr);
    }

    function deposit(uint256 _amount) public {
        require(_amount>0,"Amount must be greater than zero");
        myToken.transferFrom(msg.sender, address(this), _amount);
        balances[msg.sender] += _amount;

        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external {
        // uint256 _amount = balances[msg.sender];
        require(_amount > 0, "No balance to withdraw");
        myToken.transfer(msg.sender, _amount);
        balances[msg.sender] -= _amount;

        emit Withdraw(msg.sender, _amount);        
    }



}
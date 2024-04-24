// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
扩展 TokenBank, 在TokenBank 中利用上一题的转账回调实现存款。
*/

import "./MyERC20.sol";
contract TokenBank {
    mapping(address => uint256) balances;
    MyERC20 public myToken;

    event Deposit(address indexed _account,uint256 _amount);
    event Withdraw(address indexed _account,uint256 _amount);

    constructor (address _addr) {
        myToken =  MyERC20(_addr);
    }

    function deposit(uint256 _amount) public {
        require(_amount>0,"Amount must be greater than zero");
        myToken.transferFromWithCallBack(msg.sender, address(this), _amount);
        balances[msg.sender] += _amount;

        emit Deposit(msg.sender, _amount);
    }

    function withdraw() external {
        uint256 _amount = balances[msg.sender];
        require(_amount > 0, "No balance to withdraw");
        myToken.transferWithCallBack(msg.sender, _amount);
        balances[msg.sender] -= _amount;

        emit Withdraw(msg.sender, _amount);        
    }



}
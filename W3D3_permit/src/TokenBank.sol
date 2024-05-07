// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

//修改 TokenBank 存款合约 ,添加一个函数 permitDeposit 以支持离线签名授权（permit）进行存款。

import "./PToken.sol";

contract TokenBank {
  mapping(address => uint256) public balances;
  PToken public pToken;

  event Deposit(address indexed _account, uint256 _amount);
  event Withdraw(address indexed _account, uint256 _amount);

  constructor(address _addr) {
    pToken = PToken(_addr);
  }

  function deposit(uint256 _amount) public {
    require(_amount > 0, "Amount must be greater than zero");
    pToken.transferFrom(msg.sender, address(this), _amount);
    balances[msg.sender] += _amount;

    emit Deposit(msg.sender, _amount);
  }

  function withdraw() external {
    uint256 _amount = balances[msg.sender];
    require(_amount > 0, "No balance to withdraw");
    pToken.transfer(msg.sender, _amount);
    balances[msg.sender] -= _amount;

    emit Withdraw(msg.sender, _amount);
  }

  //添加一个函数 permitDeposit 以支持离线签名授权（permit）进行存款
  function permitDeposit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public {
    //调用PToken合约的permit方法
    pToken.permit(owner, spender, value, deadline, v, r, s);
    deposit(value);
  }
}

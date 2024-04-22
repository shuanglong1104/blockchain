//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "BigBank.sol";
contract Ownable{
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    receive() external payable { }

    modifier onlyOwner(){
        require(msg.sender==owner,"Not the owner");
        _;
    }
    //查看余额
    function getBalance(address addr) public view returns (uint){
        return address(addr).balance;
    }

    //实现只有Ownable 可以调用 BigBank 的 withdraw()
    function withdraw(address payable bank) external  {
        BigBank(bank).withdraw();
    }

}
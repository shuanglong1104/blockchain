//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 编写一个 Bank 合约，实现功能：
// 可以通过 Metamask 等钱包直接给 Bank 合约地址存款
// 在 Bank 合约你几率每个地址的存款金额
// 编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
// 用数组记录存款金额的前 3 名用户

contract Bank{
    //存款
    mapping (address => uint) public deposits;
    //定义admin
    address public admin;
    //存款金额的前3名
    address[3] public top3Addr;

    modifier onlyAdmin(){
        require(msg.sender == admin,"only admin can operate");
        _;
    }

    //部署的时候定义管理员
    constructor() {
        admin = msg.sender;
    }

    //仅管理员可以通过该方法提取资金。
    function withdraw(uint amount) public onlyAdmin {
        require(address(this).balance>=amount,"amount not enouth");
        payable(msg.sender).transfer(amount);
    }

    //更新前3列表
    function updateTop3Depositors(address depositor,uint amount) internal{
        for(uint i=0;i<top3Addr.length;i++){
            if (amount > deposits[top3Addr[i]]){
                for (uint j=top3Addr.length-1; j>i; j--) {
                    top3Addr[j] = top3Addr[j-1];
                }
                top3Addr[i] = depositor;
                break ;
            }
        }
    }

    //通过 Metamask 等钱包直接给 Bank 合约地址存款
    receive() external payable {
        deposits[msg.sender] += msg.value;
        updateTop3Depositors(msg.sender, msg.value);
    }
}



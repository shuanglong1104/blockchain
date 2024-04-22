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

    //管理员可以通过该方法提取所有资金。
    function withdraw() public virtual onlyAdmin {
        uint amount = address(this).balance;
        require(amount>0,"balance not enouth");
        payable(admin).transfer(amount);
    }
    //其他用户取钱
    function withdraw(address addr, uint amount) public virtual onlyAdmin{
        require(deposits[addr] >= amount, "balance not enouth");
        deposits[addr] -= amount;
        payable(addr).transfer(amount);
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
        deposit();
    }

    function deposit() public payable virtual  {
        deposits[msg.sender] += msg.value;
        updateTop3Depositors(msg.sender, msg.value);
    }
}



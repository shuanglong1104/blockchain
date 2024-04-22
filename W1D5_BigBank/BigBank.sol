//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
编写一个 BigBank 合约， 它继承自该挑战 的 Bank 合约，并实现功能：

要求存款金额 >0.001 ether（用modifier权限控制）
BigBank 合约支持转移管理员
同时编写一个 Ownable 合约，把 BigBank 的管理员转移给Ownable 合约， 实现只有Ownable 可以调用 BigBank 的 withdraw().
编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
用数组记录存款金额的前 3 名用户
*/

import "Bank.sol";
contract BigBank is Bank{

    modifier limitDeposit{
        require(msg.value>0.001 ether,"the deposit amount is greater than 0.001 ehter");
        _;
    }
    //override Bnak合约的deposit方法并加上modifier权限控制
    function deposit() public payable limitDeposit override {
        super.deposit();
    }

    // BigBank 合约支持转移管理员
    function transferAdmin(address newAdmin) external onlyAdmin{
        admin = newAdmin;
    }

    // 编写 withdraw() 方法，仅管理员可以通过该方法提取资金
    function withdraw() public override onlyAdmin{
        super.withdraw();
    }
    function withdraw(address addr, uint amount) public override onlyAdmin{
        super.withdraw(addr, amount);
    }

}



// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

//使用 EIP2612 标准（可基于 Openzepplin 库）编写一个自己名称的 Token 合约。
contract PToken is ERC20, ERC20Permit {
    constructor(
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) ERC20Permit(name) {
        _mint(msg.sender, 10 ** 18);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RNTIDO {
  event presale(address indexed user, uint256 amount);

  uint256 public constant PRICE = 0.00001 ether;
  uint256 public constant SOFTCAP = 21 ether;
  uint256 public constant HARDCAP = 2100 ether;
  uint256 public immutable END_AT;
  uint256 public immutable TOTAL_SUPPLY = SOFTCAP / PRICE;
  IERC20 public immutable RNT;

  uint256 public totalSold;
  uint256 public totalRaised;
  mapping(address => uint256) public balances;
  address public owner;

  constructor(IERC20 RNT_) {
    END_AT = block.timestamp + 14 days;
    RNT = RNT_;
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "only owner can operate");
    _;
  }

  function presaleRNT(uint256 amount) external payable {
    require(block.timestamp <= END_AT, "Presale has ended");
    require(msg.value == amount * PRICE, "Invalid amount");
    require(totalRaised + msg.value <= HARDCAP, "Hardcap reached");

    totalSold += amount;
    totalRaised += msg.value;
    balances[msg.sender] += amount;

    require(RNT.balanceOf(address(this)) >= totalSold, "Not enough token");
    emit presale(msg.sender, amount);
  }

  function claim() external {
    require(block.timestamp > END_AT, "Presale has not ended");
    require(totalRaised >= SOFTCAP, "Softcap not reached");

    uint256 amount = balances[msg.sender];
    require(amount > 0, "No token to claim");

    balances[msg.sender] = 0; // clear balance
    require(RNT.transfer(msg.sender, amount), "RNT transfer failed"); // send token
  }

  function refund() external {
    require(block.timestamp > END_AT, "Presale has not ended");
    require(totalRaised < SOFTCAP, "Softcap reached");

    uint256 amount = balances[msg.sender];
    require(amount > 0, "No token to refund");

    balances[msg.sender] = 0; // clear balance
    (bool ok, ) = msg.sender.call{value: amount * PRICE}(""); // refund
    require(ok, "Refund failed");
  }

  function withdraw() external onlyOwner {
    require(block.timestamp > END_AT, "Presale has not ended");
    require(totalRaised >= SOFTCAP, "Softcap not reached");

    (bool ok, ) = msg.sender.call{value: totalRaised}(""); // withdraw
    require(ok, "Withdraw failed");
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

contract MyWallet {
  string public name;
  mapping(address => bool) private approved;
  address public owner;

  modifier auth() {
    require(msg.sender == getOwner(), "Not authorized");
    _;
  }

  constructor(string memory _name) {
    name = _name;
    setOwner(msg.sender);
  }

  function transferOwernship(address _addr) public auth {
    require(_addr != address(0), "New owner is the zero address");
    require(getOwner() != _addr, "New owner is the same as the old owner");
    setOwner(_addr);
  }

  function getOwner() public view returns (address) {
    address sOwner;
    assembly {
      sOwner := sload(0x00)
    }
    return sOwner;
  }

  function setOwner(address _addr) public {
    assembly {
      sstore(0x00, _addr)
    }
  }
}

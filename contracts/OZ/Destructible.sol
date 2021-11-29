// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {

  constructor() payable { }

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() onlyOwner public {
    address owner=owner();
    address payable addr = payable(owner);
    selfdestruct(addr);
  }

  function destroyAndSend(address _recipient) onlyOwner public {
    address payable addr = payable(_recipient);
    selfdestruct(addr);
  }
}

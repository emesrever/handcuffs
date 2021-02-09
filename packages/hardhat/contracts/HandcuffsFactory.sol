pragma solidity >=0.6.0 <0.7.0;
//SPDX-License-Identifier: MIT

/****************************************************************
** @title Handcuffs factory using OpenZeppelin Escrow
** @author Jack Yin
**/

import "hardhat/console.sol";
import "./Handcuffs.sol";
// import "@openzeppelin/contracts/payment/escrow/ConditionalEscrow.sol";
// import "@openzeppelin/contracts/payment/PullPayment.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
import "@openzeppelin/contracts/math/SafeMath.sol";

contract HandcuffsFactory is Ownable {
  using SafeMath for uint256;


  Handcuffs public handcuffs;
  address payable wallet;

  constructor(address payable _wallet) public {
    handcuffs = new Handcuffs(_wallet, _wallet);
    wallet = _wallet;
  }

  /**
  * Receives payments from customers
  */
  function sendPayment() external payable {
      handcuffs.deposit.value(msg.value)(wallet);
  }

  /* function whoGetsMoneyHandcuffsBen() public view returns (address payable) {
      return handcuffs.beneficiary;
  }

  function whoGetsMoneyFactoryWallet() external view returns (address) {
      return wallet;
  } */

  /**
   * Withdraw funds to wallet
   */
  function withdraw() external
      // onlyOwner
      {
      handcuffs.withdraw(wallet);
  }

  /**
   * Checks balance available to withdraw
   * @return the balance
   */
  function balance() external view
    // onlyOwner
    returns (uint256)
  {
      return handcuffs.depositsOf(wallet);
  }

    // todo: provide public methods that redirect to the escrow's deposit and withdraw

}

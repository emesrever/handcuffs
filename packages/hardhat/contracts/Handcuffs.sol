pragma solidity >=0.6.0 <0.7.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/payment/escrow/ConditionalEscrow.sol";
// import "@openzeppelin/contracts/payment/PullPayment.sol";
// import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Handcuffs is ConditionalEscrow{

  address depositor;
  address beneficiary;

  constructor(address _depositor, address _beneficiary) public {
    depositor = _depositor;
    beneficiary = _beneficiary;
  }

  function withdrawalAllowed(address _payee) public view override returns(bool){
   // return(_payee == beneficiary);
   console.log("WithdrawalAllowed called");
   return(false);
  }

}

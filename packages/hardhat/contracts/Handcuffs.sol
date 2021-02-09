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

   console.log("WithdrawalAllowed called, result: ", _payee == beneficiary);
   // return(false);
   return(_payee == beneficiary);
  }

  /* function withdraw(address payable payee) public override {
        require(withdrawalAllowed(payee), "ConditionalEscrow: payee is not allowed to withdraw");
        super.withdraw(payee);
    } */

}

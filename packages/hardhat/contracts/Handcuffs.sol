pragma solidity >=0.6.0 <0.7.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/payment/PullPayment.sol";
// import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Handcuffs {

  address depositor;
  address beneficiary;

  constructor(address _depositor, address _beneficiary) public {
    // what should we do on deploy?
    depositor = _depositor;
    beneficiary = _beneficiary;

  }

  function deposit() public payable {

  }

  // Function to withdraw all Ether from this contract.
   function withdraw() public {
       // get the amount of Ether stored in this contract
       uint amount = address(this).balance;

       // send all Ether to beneficiary
       // beneficiary can receive Ether since the address of owner is payable
       (bool success,) = beneficiary.call{value: amount}("");
       require(success, "Failed to send Ether");
   }

}

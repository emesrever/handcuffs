pragma solidity >=0.6.0 <0.8.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./TimelockEscrow.sol";

// import "@openzeppelin/contracts/payment/PullPayment.sol";

contract Handcuffs {
    TimelockEscrow private _escrow;

    constructor() public {
        _escrow = new TimelockEscrow();
    }

    function deposit() public payable {
        _asyncTransfer(msg.sender, msg.value);
    }

    function withdraw() public {
        _escrow.withdraw(msg.sender);
    }

    function payments(address dest) public view returns (uint256) {
        return _escrow.depositsOf(dest);
    }

    receive() external payable {
        deposit();
    }

    function _asyncTransfer(address dest, uint256 amount) internal virtual {
        _escrow.deposit{value: amount}(dest);
    }
}

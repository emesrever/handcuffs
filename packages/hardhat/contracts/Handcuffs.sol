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

    function withdraw(uint256 vaultIndex) public {
        _escrow.withdraw(msg.sender, vaultIndex);
    }

    // catches if you send to the contract as if it's an address.
    receive() external payable {
        deposit();
    }

    // creates a new TimelockEscrow vault
    function _asyncTransfer(address dest, uint256 amount) internal virtual {
        _escrow.deposit{value: amount}(dest);
    }

    function getVaultAmount(address owner, uint256 vaultIndex)
        public
        view
        returns (uint256)
    {
        return _escrow.getVaultAmount(owner, vaultIndex);
    }
}

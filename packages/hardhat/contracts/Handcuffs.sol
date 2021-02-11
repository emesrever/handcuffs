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

    function deposit(uint256 lock_seconds) public payable {
        _asyncTransfer(msg.sender, msg.value, lock_seconds);
    }

    function withdraw(uint256 vaultIndex) public {
        _escrow.withdraw(msg.sender, vaultIndex);
    }

    // function viewMyVaults() public view returns (uint256) {
    //     return _escrow.get10Vaults(msg.sender);
    // }

    // catches if you send to the contract as if it's an address.
    receive() external payable {
        deposit(0);
        // assume that it shouldn't be locked
    }

    // creates a new TimelockEscrow vault
    function _asyncTransfer(
        address dest,
        uint256 amount,
        uint256 lock_seconds
    ) internal virtual {
        _escrow.deposit{value: amount}(dest, lock_seconds);
    }

    function getVaultInfo(address owner, uint256 vaultIndex)
        public
        view
        returns (uint256, uint256)
    {
        return _escrow.getVaultInfo(owner, vaultIndex);
    }

    function getVaultCount(address owner) public view returns (uint256) {
        return _escrow.getVaultCount(owner);
    }
}

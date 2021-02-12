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

    function deposit(
        address beneficiary,
        uint256 vaultIndex
    ) public payable {
        _escrow.deposit{value: msg.value}(
            beneficiary,
            vaultIndex
        );
    }

    function withdraw(uint256 vaultIndex) public {
        _escrow.withdraw(msg.sender, vaultIndex);
    }

    function signWithdraw(address owner, uint256 vaultIndex) public {
        _escrow.signWithdraw(msg.sender, owner, vaultIndex);
    }

    // creates a new TimelockEscrow vault
    function createVault(
        address dest,
        uint256 numConfirmations,
        uint256 lock_seconds,
        address guardianOne,
        address guardianTwo,
        address guardianThree
    ) public payable {
        _escrow.createVault{value: msg.value}(
            dest,
            lock_seconds,
            numConfirmations,
            guardianOne,
            guardianTwo,
            guardianThree
        );
    }

    function getVaultInfo(address owner, uint256 vaultIndex)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            bool,
            address,
            bool,
            address,
            bool
        )
    {
        return _escrow.getVaultInfo(owner, vaultIndex);
    }

    function getVaultCount(address owner) public view returns (uint256) {
        return _escrow.getVaultCount(owner);
    }
}

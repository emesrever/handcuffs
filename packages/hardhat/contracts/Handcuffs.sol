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
        uint256 lock_seconds,
        address guardianOne,
        address guardianTwo
    ) public payable {
        _asyncTransfer(
            msg.sender,
            msg.value,
            lock_seconds,
            guardianOne,
            guardianTwo
        );
    }

    function withdraw(uint256 vaultIndex) public {
        _escrow.withdraw(msg.sender, vaultIndex);
    }

    function signWithdraw(address owner, uint256 vaultIndex) public {
        _escrow.signWithdraw(msg.sender, owner, vaultIndex);
    }

    // creates a new TimelockEscrow vault
    function _asyncTransfer(
        address dest,
        uint256 amount,
        uint256 lock_seconds,
        address guardianOne,
        address guardianTwo
    ) internal virtual {
        _escrow.deposit{value: amount}(
            dest,
            lock_seconds,
            guardianOne,
            guardianTwo
        );
    }

    function getVaultInfo(address owner, uint256 vaultIndex)
        public
        view
        returns (
            uint256,
            uint256,
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

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
        uint256 lockSeconds,
        uint256 numConfirmations,
        address guardianOne,
        address guardianTwo,
        address guardianThree,
        address beneficiary
    ) public payable {
        _asyncTransfer(
            msg.sender,
            msg.value,
            lockSeconds,
            numConfirmations,
            guardianOne,
            guardianTwo,
            guardianThree,
            beneficiary
        );
    }

    function withdraw(uint256 vaultIndex) public {
        _escrow.withdraw(msg.sender, vaultIndex);
    }

    function signWithdraw(address creator, uint256 vaultIndex) public {
        _escrow.signWithdraw(msg.sender, creator, vaultIndex);
    }

    // creates a new TimelockEscrow vault
    function _asyncTransfer(
        address creator,
        uint256 amount,
        uint256 lockSeconds,
        uint256 numConfirmations,
        address guardianOne,
        address guardianTwo,
        address guardianThree,
        address beneficiary
    ) internal virtual {
        _escrow.deposit{value: amount}(
            creator,
            lockSeconds,
            numConfirmations,
            guardianOne,
            guardianTwo,
            guardianThree,
            beneficiary
        );
    }

    function getVaultInfo(address creator, uint256 vaultIndex)
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
        return _escrow.getVaultInfo(creator, vaultIndex);
    }

    function getVaultCount(address creator) public view returns (uint256) {
        return _escrow.getVaultCount(creator);
    }
}

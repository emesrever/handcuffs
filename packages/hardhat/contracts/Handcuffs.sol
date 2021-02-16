pragma solidity >=0.6.0 <0.8.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./TimelockMultisigWallet.sol";

// import "@openzeppelin/contracts/payment/PullPayment.sol";

contract Handcuffs {

    mapping(address => TimelockMultisigWallet[]) public wallets;

    function deposit(
        address beneficiary,
        uint256 vaultIndex
    ) public payable {
        wallets[beneficiary][vaultIndex].deposit{value: msg.value}();
    }

    function withdraw(uint256 vaultIndex) public {
        wallets[msg.sender][vaultIndex].withdraw();
    }

    function signWithdraw(address beneficiary, uint256 vaultIndex) public {
        wallets[beneficiary][vaultIndex].signWithdraw(msg.sender);
    }

    // creates a new TimelockEscrow vault
    function createWallet(
        address beneficiary,
        uint256 numConfirmations,
        uint256 lock_seconds,
        address guardianOne,
        address guardianTwo,
        address guardianThree
    ) public payable {
        wallets[beneficiary].push(
            new TimelockMultisigWallet{value: msg.value}(
                    beneficiary,
                    lock_seconds,
                    numConfirmations,
                    guardianOne,
                    guardianTwo,
                    guardianThree
                )
            );
    }

    function getWalletInfo(address beneficiary, uint256 vaultIndex)
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
        return wallets[beneficiary][vaultIndex].getInfo();
    }

    function getVaultCount(address beneficiary) public view returns (uint256) {
        return wallets[beneficiary].length;
    }
}

pragma solidity >=0.6.0 <0.8.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

// import "@openzeppelin/contracts/payment/PullPayment.sol";

contract Handcuffs {
    using SafeERC20 for IERC20;

    mapping(address => TimelockMultisigWallet[]) public wallets;

    function deposit(
        address beneficiary,
        uint256 vaultIndex
    ) public payable {
        wallets[beneficiary][vaultIndex].deposit{value: msg.value}();
    }

    // TODO: figure out what's up with this function
    // unclear if this function is strictly necessary
    // Theoretically if people knew the address of this contract, they
    // could just send to the address directly

    // Jack's answer - the point of this function was to get wallet address
    // in the scaffold-eth UI and be able to send to the wallet directly.
    // It's not strictly necessary.
    function getWalletAddress(address beneficiary, uint256 vaultIndex)
        public
        view
        returns(address){
        console.log(address(wallets[beneficiary][vaultIndex]), " is the wallet address");
        return address(wallets[beneficiary][vaultIndex]);
    }

    function withdraw(uint256 vaultIndex) public {
        wallets[msg.sender][vaultIndex].withdraw();
    }

    function withdrawTokens(uint256 vaultIndex, address tokenContract) public {
        wallets[msg.sender][vaultIndex].withdrawTokens(tokenContract);
    }

    function signWithdraw(address beneficiary, uint256 vaultIndex) public {
        wallets[beneficiary][vaultIndex].signWithdraw(msg.sender);
    }

    // creates a new TimelockEscrow vault
    function createWallet(
        address payable beneficiary,
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

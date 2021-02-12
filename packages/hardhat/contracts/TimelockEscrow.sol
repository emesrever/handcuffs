pragma solidity >=0.6.0 <0.8.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/payment/escrow/ConditionalEscrow.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract TimelockEscrow is Ownable {
    using Address for address payable;
    using SafeMath for uint256;

    struct Vault {
        uint256 amount;
        uint256 unlocked_timestamp;
        uint256 numConfirmations;
        address guardianOne;
        bool guardianOneSigned;
        address guardianTwo;
        bool guardianTwoSigned;
        address guardianThree;
        bool guardianThreeSigned;
    }

    mapping(address => Vault[]) private _vaults;

    modifier validVault(address owner, uint256 vaultIndex) {
        require(_vaults[owner].length > vaultIndex, "vault doesnt exist");
        _;
    }

    modifier validSigner(
        address signee,
        address owner,
        uint256 vaultIndex
    ) {
        require(
            _vaults[owner][vaultIndex].guardianOne == signee ||
                _vaults[owner][vaultIndex].guardianTwo == signee ||
                _vaults[owner][vaultIndex].guardianThree == signee,
            "invalid signer"
        );
        _;
    }

    // returns vault amount
    function getVaultInfo(address owner, uint256 vaultIndex)
        public
        view
        onlyOwner
        validVault(owner, vaultIndex)
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
        console.log(vaultIndex);
        console.log(_vaults[owner].length);

        Vault memory vault = _vaults[owner][vaultIndex];
        return (
            vault.amount,
            vault.unlocked_timestamp,
            vault.numConfirmations,
            vault.guardianOne,
            vault.guardianOneSigned,
            vault.guardianTwo,
            vault.guardianTwoSigned,
            vault.guardianThree,
            vault.guardianThreeSigned
        );
    }

    function getVaultCount(address owner)
        public
        view
        onlyOwner
        returns (uint256)
    {
        return _vaults[owner].length;
    }

    function deposit(
        address payee,
        uint256 lock_seconds,
        uint256 numConfirmations,
        address guardianOne,
        address guardianTwo,
        address guardianThree
    ) public payable virtual onlyOwner {
        require(payee != guardianOne &&
            payee != guardianTwo &&
            payee != guardianThree, "beneficiary cannot be guardian");
        require(guardianOne != guardianTwo &&
                guardianTwo != guardianThree &&
                guardianOne != guardianThree, "Guardians must be unique");
        require(numConfirmations <= 3, "Required Confirmations must be 3 or fewer");

        _vaults[payee].push(
            Vault({
                amount: msg.value,
                unlocked_timestamp: block.timestamp + lock_seconds,
                numConfirmations: numConfirmations,
                guardianOne: guardianOne,
                guardianOneSigned: false,
                guardianTwo: guardianTwo,
                guardianTwoSigned: false,
                guardianThree: guardianThree,
                guardianThreeSigned: false
            })
        );
    }

    function withdraw(address payable payee, uint256 vaultIndex)
        public
        virtual
        onlyOwner
        validVault(payee, vaultIndex)
    {
        require(
            withdrawalAllowed(payee, vaultIndex),
            "does not meet withdraw requirements"
        );

        uint256 payment = _vaults[payee][vaultIndex].amount;

        _vaults[payee][vaultIndex].amount = 0;

        payee.sendValue(payment);
    }

    function signWithdraw(
        address signer,
        address owner,
        uint256 vaultIndex
    )
        public
        validVault(owner, vaultIndex)
        validSigner(signer, owner, vaultIndex)
        onlyOwner
    {
        if (signer == _vaults[owner][vaultIndex].guardianOne) {
            _vaults[owner][vaultIndex].guardianOneSigned = true;
        }

        if (signer == _vaults[owner][vaultIndex].guardianTwo) {
            _vaults[owner][vaultIndex].guardianTwoSigned = true;
        }

        if (signer == _vaults[owner][vaultIndex].guardianThree) {
            _vaults[owner][vaultIndex].guardianThreeSigned = true;
        }
    }

    function withdrawalAllowed(address payee, uint256 vaultIndex)
        public
        view
        onlyOwner
        returns (bool)
    {
        if (
            block.timestamp >= _vaults[payee][vaultIndex].unlocked_timestamp ||
            ((_vaults[payee][vaultIndex].guardianOneSigned ? 1 : 0) +
                (_vaults[payee][vaultIndex].guardianTwoSigned ? 1 : 0) +
                (_vaults[payee][vaultIndex].guardianThreeSigned ? 1 : 0) >=
                _vaults[payee][vaultIndex].numConfirmations)
        ) {
            return true;
        } else {
            return false;
        }
    }
}

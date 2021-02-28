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
        uint256 unlockedTimestamp;
        uint256 numConfirmations;
        address guardianOne;
        bool guardianOneSigned;
        address guardianTwo;
        bool guardianTwoSigned;
        address guardianThree;
        bool guardianThreeSigned;
        address beneficiary;
    }

    mapping(address => Vault[]) private _vaults;

    modifier validVault(address creator, uint256 vaultIndex) {
        require(_vaults[creator].length > vaultIndex, "vault doesnt exist");
        _;
    }

    modifier validSigner(
        address signee,
        address creator,
        uint256 vaultIndex
    ) {
        require(
            _vaults[creator][vaultIndex].guardianOne == signee ||
                _vaults[creator][vaultIndex].guardianTwo == signee ||
                _vaults[creator][vaultIndex].guardianThree == signee,
            "invalid signer"
        );
        _;
    }

    // returns vault amount
    function getVaultInfo(address creator, uint256 vaultIndex)
        public
        view
        onlyOwner
        validVault(creator, vaultIndex)
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
        console.log(_vaults[creator].length);

        Vault memory vault = _vaults[creator][vaultIndex];
        return (
            vault.amount,
            vault.unlockedTimestamp,
            vault.numConfirmations,
            vault.guardianOne,
            vault.guardianOneSigned,
            vault.guardianTwo,
            vault.guardianTwoSigned,
            vault.guardianThree,
            vault.guardianThreeSigned
        );
    }

    function getVaultCount(address creator)
        public
        view
        onlyOwner
        returns (uint256)
    {
        return _vaults[creator].length;
    }

    function deposit(
        address creator,
        uint256 lockSeconds,
        uint256 numConfirmations,
        address guardianOne,
        address guardianTwo,
        address guardianThree,
        address beneficiary
    ) public payable virtual onlyOwner {
        require(
            beneficiary != guardianOne &&
                beneficiary != guardianTwo &&
                beneficiary != guardianThree,
            "beneficiary cannot be guardian"
        );
        require(
            guardianOne != guardianTwo &&
                guardianTwo != guardianThree &&
                guardianOne != guardianThree,
            "Guardians must be unique"
        );
        require(
            numConfirmations <= 3,
            "Required Confirmations must be 3 or fewer"
        );

        _vaults[creator].push(
            Vault({
                amount: msg.value,
                unlockedTimestamp: block.timestamp + lockSeconds,
                numConfirmations: numConfirmations,
                guardianOne: guardianOne,
                guardianOneSigned: false,
                guardianTwo: guardianTwo,
                guardianTwoSigned: false,
                guardianThree: guardianThree,
                guardianThreeSigned: false,
                beneficiary: beneficiary
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
        address creator,
        uint256 vaultIndex
    )
        public
        validVault(creator, vaultIndex)
        validSigner(signer, creator, vaultIndex)
        onlyOwner
    {
        if (signer == _vaults[creator][vaultIndex].guardianOne) {
            _vaults[creator][vaultIndex].guardianOneSigned = true;
        } else if (signer == _vaults[creator][vaultIndex].guardianTwo) {
            _vaults[creator][vaultIndex].guardianTwoSigned = true;
        } else if (signer == _vaults[creator][vaultIndex].guardianThree) {
            _vaults[creator][vaultIndex].guardianThreeSigned = true;
        }
    }

    function withdrawalAllowed(address payee, uint256 vaultIndex)
        public
        view
        onlyOwner
        returns (bool)
    {
        if (
            block.timestamp >= _vaults[payee][vaultIndex].unlockedTimestamp ||
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

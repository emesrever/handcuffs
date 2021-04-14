pragma solidity >=0.6.0 <0.8.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

// import "@openzeppelin/contracts/payment/PullPayment.sol";

contract Handcuffs {
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

    /*                             Modifiers                                  */
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

    modifier validVault(address creator, uint256 vaultIndex) {
        require(_vaults[creator].length > vaultIndex, "vault doesnt exist");
        _;
    }

    modifier withdrawalAllowed(
        address creator,
        uint256 vaultIndex,
        address beneficiary
    ) {
        require(
            // Vault is past time lock
            (block.timestamp >=
                _vaults[creator][vaultIndex].unlockedTimestamp) ||
                // Vault is signed by enough guardians
                (((_vaults[creator][vaultIndex].guardianOneSigned ? 1 : 0) +
                    (_vaults[creator][vaultIndex].guardianTwoSigned ? 1 : 0) +
                    (
                        _vaults[creator][vaultIndex].guardianThreeSigned ? 1 : 0
                    )) >= _vaults[creator][vaultIndex].numConfirmations),
            "vault not eligible for withdraw yet"
        );

        require(
            _vaults[creator][vaultIndex].beneficiary == beneficiary,
            "Only the beneficiary can withdraw from the vault"
        );
        _;
    }

    /*                            End Modifiers                               */

    function createVaultSelfBeneficiary(
        uint256 lockSeconds,
        uint256 numConfirmations,
        address guardianOne,
        address guardianTwo,
        address guardianThree
    ) public payable {
        createVaultOtherBeneficiary(
            lockSeconds,
            numConfirmations,
            guardianOne,
            guardianTwo,
            guardianThree,
            msg.sender
        );
    }

    function createVaultOtherBeneficiary(
        uint256 lockSeconds,
        uint256 numConfirmations,
        address guardianOne,
        address guardianTwo,
        address guardianThree,
        address beneficiary
    ) public payable {
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

        _vaults[msg.sender].push(
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

    function depositIntoExistingVault(address creator, uint256 vaultIndex)
        public
        payable
        validVault(creator, vaultIndex)
    {
        _vaults[creator][vaultIndex].amount += msg.value;
    }

    function withdraw(
        address payable withdrawTo,
        address creator,
        uint256 vaultIndex
    )
        public
        validVault(creator, vaultIndex)
        // the below verifies it is eligible and that the sender is the beneficiary
        withdrawalAllowed(creator, vaultIndex, msg.sender)
    {
        uint256 withdrawAmount = _vaults[creator][vaultIndex].amount;

        _vaults[creator][vaultIndex].amount = 0;

        // TODO: figure out error handling here, is this the correct send?
        (bool success, ) = withdrawTo.call{value: withdrawAmount}("");
        require(success, "Failed to send Ether");
    }

    function signWithdraw(address creator, uint256 vaultIndex)
        public
        validVault(creator, vaultIndex)
        validSigner(msg.sender, creator, vaultIndex)
    {
        if (msg.sender == _vaults[creator][vaultIndex].guardianOne) {
            _vaults[creator][vaultIndex].guardianOneSigned = true;
        } else if (msg.sender == _vaults[creator][vaultIndex].guardianTwo) {
            _vaults[creator][vaultIndex].guardianTwoSigned = true;
        } else if (msg.sender == _vaults[creator][vaultIndex].guardianThree) {
            _vaults[creator][vaultIndex].guardianThreeSigned = true;
        }
    }

    function getVaultInfo(address creator, uint256 vaultIndex)
        public
        view
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

    function getVaultCount(address creator) public view returns (uint256) {
        return _vaults[creator].length;
    }
}

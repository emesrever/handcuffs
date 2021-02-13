pragma solidity >=0.6.0 <0.8.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/payment/escrow/ConditionalEscrow.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

contract TimelockMultisigWallet is Ownable {
    using Address for address payable;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public beneficiary
    uint256 public amount;
    uint256 public unlocked_timestamp;
    uint256 public numConfirmations;
    address public guardianOne;
    bool public guardianOneSigned;
    address public guardianTwo;
    bool public guardianTwoSigned;
    address public guardianThree;
    bool public guardianThreeSigned;

    modifier validSigner(
        address signee
    ) {
        require(
            guardianOne == signee ||
            guardianTwo == signee ||
            guardianThree == signee,
            "invalid signer"
        );
        _;
    }

    // returns vault amount
    function getInfo()
        public
        view
        onlyOwner
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
        return (
            amount,
            unlocked_timestamp,
            numConfirmations,
            guardianOne,
            guardianOneSigned,
            guardianTwo,
            guardianTwoSigned,
            guardianThree,
            guardianThreeSigned
        );
    }

    constructor(
        address _payee,
        uint256 _lock_seconds,
        uint256 _numConfirmations,
        address _guardianOne,
        address _guardianTwo,
        address _guardianThree
    ) public payable virtual onlyOwner {
        require(_payee != _guardianOne &&
            _payee != _guardianTwo &&
            _payee != _guardianThree, "beneficiary cannot be guardian");
        require(_guardianOne != _guardianTwo &&
                _guardianTwo != _guardianThree &&
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

    function deposit(address payee, uint256 vaultIndex) public payable virtual onlyOwner
        validVault(payee, vaultIndex)
    {
            _vaults[payee][vaultIndex].amount += msg.value;
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

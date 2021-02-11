pragma solidity >=0.6.0 <0.8.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
// import "@openzeppelin/contracts/payment/escrow/ConditionalEscrow.sol";
// Heavily modeled off of Conditional Escrow but doesn't implement it
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract TimelockMultiSigEscrow is Ownable {
    using Address for address payable;
    using SafeMath for uint256;

    struct Vault {
        uint256 amount;
        uint256 unlocked_timestamp;
        // start with 2 addresses, they all have to sign
        (address, bool)[] guardians;
        mapping(address => bool) isGuardian;
        uint256 num_guardians_needed;
        mapping(address => bool) isConfirmed;
        uint256 num_confirmations;
    }

    mapping(address => Vault[]) private _vaults;

    modifier vaultExists(address owner, uint256 vaultIndex) {
        require(vaultIndex < _vaults[owner].length, "vault does not exist");
        _;
    }

    modifier notConfirmed(address owner, uint256 vaultIndex, address guardian) {
        require(!_vaults[owner][vaultIndex].isConfirmed[guardian],
            "guardian already confirmed for that vault");
        _;
    }

    // helper function to iterate through array and return if x is a member of an array


    // returns vault amount
    function getVaultInfo(address owner, uint256 vaultIndex)
        public
        view
        onlyOwner
        vaultExists(owner, vaultIndex)
        returns (uint256,
            uint256,
            address,
            address,
            uint256,
            uint256)
    {
        console.log(vaultIndex);
        console.log(_vaults[owner].length);
        return (
            _vaults[owner][vaultIndex].amount,
            _vaults[owner][vaultIndex].unlocked_timestamp,
            _vaults[owner][vaultIndex].guardians[0],
            _vaults[owner][vaultIndex].guardians[1],
            _vaults[owner][vaultIndex].num_guardians_needed,
            _vaults[owner][vaultIndex].num_confirmations
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

    // function get10Vaults(address owner) public view returns (uint256) {
    //     uint256[] memory amounts = new uint256[](10);
    //     uint256[] memory unlocked_timestamps = new uint256[](10);

    //     for (uint256 i = 0; i < _vaults[owner].length && i < 10; ++i) {
    //         amounts[i] = _vaults[owner][i].amount;
    //         unlocked_timestamps[i] = _vaults[owner][i].unlocked_timestamp;
    //     }

    //     return (amounts[0]);
    // }

    function deposit(address payee,
                    uint256 lock_seconds,
                    address guardian_0,
                    address guardian_1,
                    uint256 num_guardians_needed
                    )
        public
        payable
        virtual
        onlyOwner
    {
        // TODO: put some checks around number of guardians
        // and nuM_guardians_needed - it can't be larger
        address[] storage _guardians;
        _guardians[0] = guardian_0;
        _guardians[1] = guardian_1;
        mapping(address => bool) storage _isGuardian;
        mapping(address => bool) storage _isConfirmed;

        for (uint i = 0; i < _guardians.length; i++) {
            address _guardian = _guardians[i];

            require(_guardian != address(0), "invalid guardian");
            require(!_isGuardian[_guardian], "owner not unique");

            _isGuardian[_guardian] = true;
            // owners.push(owner);
        }

        /* _vaults[payee].push(
            Vault({
                amount: msg.value,
                unlocked_timestamp: block.timestamp + lock_seconds,
                guardians: _guardians,
                num_guardians_needed: num_guardians_needed,
                num_confirmations: 0,
                isGuardian: _isGuardian,
                isConfirmed: _isConfirmed
            })
        ); */
    }

    // each guardian needs to
    function confirmWithdrawal(address payee, uint vaultIndex,
                                address guardian)
        public
        onlyOwner
        vaultExists(payee, vaultIndex)
        notConfirmed(payee, vaultIndex, guardian)
    {
        require(_vaults[payee][vaultIndex].isGuardian[guardian], "Invalid guardian for this vault");
        _vaults[payee][vaultIndex].numConfirmations += 1;
        _vaults[payee][vaultIndex].isConfirmed[guardian] = true;
    }

    function withdraw(address payable payee, uint256 vaultIndex)
        public
        virtual
        onlyOwner
    {
        // requirements
        require(_vaults[payee].length > vaultIndex, "vault index too high");
        require(
            withdrawalAllowed(payee, vaultIndex),
            "does not meet withdraw requirements"
        );

        uint256 payment = _vaults[payee][vaultIndex].amount;

        _vaults[payee][vaultIndex].amount = 0;

        payee.sendValue(payment);
    }

    function withdrawalAllowed(address payee, uint256 vaultIndex)
        public
        view
        onlyOwner
        returns (bool)
    {
        // if guardians sign off, then it's okay
        if (_vaults[payee][vaultIndex].num_confirmations >=
            _vaults[payee][vaultIndex].num_guardians_needed) {
            return true;
        }
        // if guardians didn't sign off, then check the time lock
        if (block.timestamp > _vaults[payee][vaultIndex].unlocked_timestamp) {
            return true;
        }


        return false;
    }
}

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
    }

    mapping(address => Vault[]) private _vaults;

    // returns vault amount
    function getVaultAmount(address owner, uint256 vaultIndex)
        public
        view
        onlyOwner
        returns (uint256, uint256)
    {
        console.log(vaultIndex);
        console.log(_vaults[owner].length);
        require(vaultIndex < _vaults[owner].length, "vault index too high");
        return (
            _vaults[owner][vaultIndex].amount,
            _vaults[owner][vaultIndex].unlocked_timestamp
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

    function deposit(address payee, uint256 lock_seconds)
        public
        payable
        virtual
        onlyOwner
    {
        _vaults[payee].push(
            Vault({
                amount: msg.value,
                unlocked_timestamp: block.timestamp + lock_seconds
            })
        );
    }

    function withdraw(address payable payee, uint256 vaultIndex)
        public
        virtual
        onlyOwner
    {
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
        if (block.timestamp < _vaults[payee][vaultIndex].unlocked_timestamp) {
            return false;
        }
        return true;
    }
}

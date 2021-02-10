pragma solidity >=0.6.0 <0.8.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/payment/escrow/ConditionalEscrow.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TimelockEscrow is Ownable {
    struct Vault {
        uint256 amount;
        // release time
    }

    mapping(address => Vault[]) private _vaults;

    function getVaultAmount(address owner, uint256 vaultIndex)
        public
        view
        returns (uint256)
    {
        return _vaults[owner][vaultIndex].amount;
    }

    function deposit(address payee) public payable virtual onlyOwner {
        _vaults[payee].push(Vault({amount: msg.value}));
    }

    function withdraw(address payable payee, uint256 vaultIndex)
        public
        virtual
        onlyOwner
    {
        require(
            withdrawalAllowed(payee, vaultIndex),
            "does not meet withdraw requirements"
        );

        require(_vaults[payee].length > vaultIndex, "vault index too high");

        uint256 payment = _vaults[payee][vaultIndex].amount;

        _vaults[payee][vaultIndex].amount = 0;

        payee.sendValue(payment);
    }

    function withdrawalAllowed(address payee, uint256 vaultIndex)
        public
        view
        returns (bool)
    {
        return true;
    }
}

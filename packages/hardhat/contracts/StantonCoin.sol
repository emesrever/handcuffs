pragma solidity >=0.6.0 <0.8.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StantonCoin is ERC20 {
    // put in your own test wallets in here to test ERC20 functionality
    constructor(uint256 initialSupply) public ERC20("StantonCoin", "STAN") {
        _mint(0x312b42DC765cb313460fF730Db8CF91f3289F5aA, initialSupply/4);
        _mint(0x85E2dC1DCc1fd46aBBD8382524Bad4332972fc3E, initialSupply/4);
        _mint(0x5dCF527aC10ea2deFc84A818fdF52029Ae3a7809, initialSupply/4);
        _mint(0x2813160A00fd287c6421496D97cE2095bB49FF02, initialSupply/4);
    }
}

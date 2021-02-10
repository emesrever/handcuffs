pragma solidity >=0.6.0 <0.8.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/payment/escrow/ConditionalEscrow.sol";

contract TimelockEscrow is ConditionalEscrow {
    function withdrawalAllowed(address payee)
        public
        view
        override
        returns (bool)
    {
        return true;
    }
}

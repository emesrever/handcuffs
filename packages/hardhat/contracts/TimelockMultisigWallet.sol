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

    address payable public beneficiary;
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
    ) public payable {
        require(_payee != _guardianOne &&
            _payee != _guardianTwo &&
            _payee != _guardianThree, "beneficiary cannot be guardian");
        require(_guardianOne != _guardianTwo &&
                _guardianTwo != _guardianThree &&
                _guardianOne != _guardianThree, "Guardians must be unique");
        require(_numConfirmations <= 3, "Required Confirmations must be 3 or fewer");

        amount = msg.value;
        unlocked_timestamp = block.timestamp + _lock_seconds;
        numConfirmations = _numConfirmations;
        guardianOne = _guardianOne;
        guardianOneSigned = false;
        guardianTwo = _guardianTwo;
        guardianTwoSigned= false;
        guardianThree = _guardianThree;
        guardianThreeSigned = false;


    }

    function deposit() public payable virtual onlyOwner
    {
            amount += msg.value;
    }

    function withdraw()
        public
        virtual
        onlyOwner
    {
        // TODO: create test - what if the payee address is not payable?
        require(
            withdrawalAllowed(),
            "does not meet withdraw requirements"
        );

        uint256 payment = amount;

        amount = 0;

        beneficiary.sendValue(payment);
    }

    /* function withdrawToken(address tokenAddress){

    } */

    function signWithdraw(address signer)
        public
        validSigner(signer)
        onlyOwner
    {
        if (signer == guardianOne) {guardianOneSigned = true;}
        if (signer == guardianTwo) {guardianTwoSigned = true;}
        if (signer == guardianThree) {guardianThreeSigned = true;}
    }

    function withdrawalAllowed()
        public
        view
        onlyOwner
        returns (bool)
    {
        if (
            block.timestamp >= unlocked_timestamp ||
            ((guardianOneSigned ? 1 : 0) +
                (guardianTwoSigned ? 1 : 0) +
                (guardianThreeSigned ? 1 : 0) >=
                numConfirmations)
        ) {
            return true;
        } else {
            return false;
        }
    }
}

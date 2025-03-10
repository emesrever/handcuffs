// need to install the openzeppelin testing suites separately:
// $ npm install --save-dev @openzeppelin/test-environment
// $ npm install --save-dev @openzeppelin/test-helpers

// TODO: add balance checks
// It's unclear how to do balance checks when there's gas fees involved
// I think OpenZeppelin has some methods to do this.

const { ethers, upgrades } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");
const { accounts, contract } = require('@openzeppelin/test-environment');
const { parseEther } = require('@ethersproject/units');

const {
  BN,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
  time,         // Time functions for converting things to seconds
  balance,      // functions for checking balance
} = require('@openzeppelin/test-helpers');

use(solidity);

// `describe` is a Mocha function that allows you to organize your tests. It's
// not actually needed, but having your tests organized makes debugging them
// easier. All Mocha functions are available in the global scope.

// `describe` receives the name of a section of your test suite, and a callback.
// The callback must define the tests of that section. This callback can't be
// an async function.
describe("Handcuffs", function () {
  // Mocha has four functions that let you hook into the the test runner's
  // lifecyle. These are: `before`, `beforeEach`, `after`, `afterEach`.

  // They're very useful to setup the environment for tests, and to clean it
  // up after they run.

  // A common pattern is to declare some variables, and assign them in the
  // `before` and `beforeEach` callbacks.
  let handcuffs_instance; // what should we call this instance?

  let owner;
  let orig_owner_balance;
  let guard1;
  let guard2;
  let guard3;
  let beneficiary;

  describe("Handcuffs", function () {
    it("Should deploy Handcuffs", async function () {
      const Handcuffs = await ethers.getContractFactory("Handcuffs");
      handcuffs_instance = await upgrades.deployProxy(Handcuffs, []);

      // Get the ContractFactory and Signers here.
      [owner, guard1, guard2, guard3, beneficiary] = await ethers.getSigners();

    });

    it("Should upgrade Handcuffs at same address", async function () {
      const Handcuffs = await ethers.getContractFactory("Handcuffs");
      const handcuffs_upgraded = await upgrades.upgradeProxy(handcuffs_instance.address, Handcuffs);

      expect(handcuffs_instance.address).to.equal(handcuffs_upgraded.address);
    });

    describe("Basic wallet functionality", function () {
      it("Create a basic wallet with no timelock, no confirmations", async function () {
        await handcuffs_instance.createVaultSelfBeneficiary(
          0, // lock_seconds
          0, // num confirmations
          guard1.address,
          guard2.address,
          guard3.address, {
            value: parseEther('1.0') // parseEther expects a string
          });
      });

      it("Basic wallet should give the expected return results", async function() {
        let getVaultInfoResults = await handcuffs_instance.getVaultInfo(owner.address, 0);

        expect(getVaultInfoResults[0]).to.equal(parseEther('1.0')); // eth amount
        // second parameter is the timestamp
        expect(getVaultInfoResults[2]).to.equal(0); // num confirmations
        expect(getVaultInfoResults[3]).to.equal(guard1.address); // Guardian one
        expect(getVaultInfoResults[4]).to.be.false; // Guardian one signed
        expect(getVaultInfoResults[5]).to.equal(guard2.address); // Guardian two
        expect(getVaultInfoResults[6]).to.be.false; // Guardian two signed
        expect(getVaultInfoResults[7]).to.equal(guard3.address); // Guardian three
        expect(getVaultInfoResults[8]).to.be.false; // Guardian three signed
      });

      it("Basic wallet should allow deposit from self", async function() {
        await handcuffs_instance.depositIntoExistingVault(owner.address, 0, {value: parseEther('1.0')});
        let getVaultInfoResults = await handcuffs_instance.getVaultInfo(owner.address, 0);
        expect(getVaultInfoResults[0]).to.equal(parseEther('2.0')); // eth amount
      });

      it("Basic wallet should allow deposit from others", async function() {
        let contractFromGuard1 = handcuffs_instance.connect(guard1);
        await contractFromGuard1.depositIntoExistingVault(owner.address, 0, {value: parseEther('1.0')});
        let getVaultInfoResults = await contractFromGuard1.getVaultInfo(owner.address, 0);
        expect(getVaultInfoResults[0]).to.equal(parseEther('3.0')); // eth amount
      });

      it("Basic wallet should not allow nonbeneficiary to withdraw", async function() {
        await expectRevert(handcuffs_instance.connect(guard2).withdraw(guard2.address, owner.address, 0),
          "Only the beneficiary can withdraw from the vault"
        );
      });

      it("Basic wallet should allow withdrawal", async function() {
        await handcuffs_instance.withdraw(owner.address, owner.address, 0);
        let getVaultInfoResults = await handcuffs_instance.getVaultInfo(owner.address, 0);
        expect(getVaultInfoResults[0]).to.equal(parseEther('0')); // eth amount
      });

    });
    describe("Multi Sig Functionality", function(){
      it("Create a multisig wallet with one year timelock, needing 2 confirmations", async function () {
        await handcuffs_instance.createVaultSelfBeneficiary(
          time.duration.years(1).toNumber(), // lock_seconds - time lock shouldn't trigger.
          // note that time.duration returns a BN, and BN objects need to be cast to the right format
          2, // num confirmations
          guard1.address,
          guard2.address,
          guard3.address, {
            value: parseEther('1.0') // parseEther expects a string
          });
      });

      it("Multi sig wallet should not be withdrawable when conditions are not met", async function() {
        await expectRevert(handcuffs_instance.withdraw(owner.address, owner.address, 1),
          "vault not eligible for withdraw yet"
        );
      });

      it("Multi Sig wallet should be withdrawable after N signatures when time has not passed",
      async function() {
        await handcuffs_instance.connect(guard1).signWithdraw(owner.address,1);
        await handcuffs_instance.connect(guard2).signWithdraw(owner.address,1);
        await handcuffs_instance.withdraw(owner.address, owner.address, 1);

        let getVaultInfoResults = await handcuffs_instance.getVaultInfo(owner.address, 1);
        expect(getVaultInfoResults[0]).to.equal(parseEther('0'));
      });
    });
    describe("Timelock functionality", function(){
      it("Create a multisig wallet with one year timelock, needing 3 confirmations", async function () {
        await handcuffs_instance.createVaultSelfBeneficiary(
          time.duration.years(1).toNumber(), // lock_seconds - time lock shouldn't trigger.
          // note that time.duration returns a BN, and BN objects need to be cast to the right format
          3, // num confirmations
          guard1.address,
          guard2.address,
          guard3.address, {
            value: parseEther('1.0') // parseEther expects a string
          });
      });

      it("Wallet should be withdrawable after the time has passed with no signatures", async function() {
        await time.increase(time.duration.years(1));
        await handcuffs_instance.withdraw(owner.address, owner.address, 1);

        let getVaultInfoResults = await handcuffs_instance.getVaultInfo(owner.address, 1);
        expect(getVaultInfoResults[0]).to.equal(parseEther('0'));
      });

    });
  });
});

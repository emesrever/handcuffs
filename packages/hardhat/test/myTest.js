// need to install the openzeppelin testing suites separately:
// $ npm install --save-dev @openzeppelin/test-environment
// $ npm install --save-dev @openzeppelin/test-helpers

const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");
const { accounts, contract } = require('@openzeppelin/test-environment');
const { parseEther } = require('@ethersproject/units');

const {
  BN,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
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
  let myContract;

  let owner;
  let guard1;
  let guard2;
  let guard3;

  describe("Handcuffs", function () {
    it("Should deploy Handcuffs", async function () {
      const Handcuffs = await ethers.getContractFactory("Handcuffs");

      myContract = await Handcuffs.deploy();

      // Get the ContractFactory and Signers here.
      [owner, guard1, guard2, guard3] = await ethers.getSigners();
    });

    describe("Wallet creation functionality", function () {
      it("Create a basic wallet with no timelock, no confirmations, with 1 eth", async function () {

         await myContract.createVaultSelfBeneficiary(
              owner,
              0, // num confirmations
              0, // lock_seconds
              guard1,
              guard2,
              guard3, {
            value: parseEther('1.0') // parseEther expects a string
        });


      });
    });
  });
});

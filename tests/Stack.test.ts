import { ethers, upgrades } from "hardhat";
import {
  Stack,
  Wallet,
  Stack__factory,
  Wallet__factory,
  MockERC20,
  MockERC20__factory,
  WalletImplementation__factory,
  WalletImplementation,
} from "../typechain";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { keccak256, getCreate2Address, parseEther } from "ethers/lib/utils";
import { BigNumber } from "ethers";
import { expect } from "chai";
import { pack, keccak256 as keccak256Ether } from "@ethersproject/solidity";
import { advanceBlock, advanceBlockTo, duration, increase, latestBlockNumber } from "./helpers/time";
import { zeroAddress } from "ethereumjs-util";

describe("Stack", () => {
  let deployer: SignerWithAddress;
  let alice: SignerWithAddress;
  let bob: SignerWithAddress;

  let stack: Stack;
  let stackAsAlice: Stack;
  let stackAsBob: Stack;

  let implementation: WalletImplementation;

  let token: MockERC20;
  let tokenAsAlice: MockERC20;
  let tokenAsBob: MockERC20;

  beforeEach(async () => {
    [deployer, alice, bob] = await ethers.getSigners();

    const MockERC20 = (await ethers.getContractFactory("MockERC20")) as MockERC20__factory;
    token = await MockERC20.deploy("ERC20", "ERC20", parseEther("1000000"));
    await token.deployed();

    const WalletImplementation = (await ethers.getContractFactory(
      "WalletImplementation"
    )) as WalletImplementation__factory;
    implementation = await WalletImplementation.deploy();
    await implementation.deployed();

    const Stack = (await ethers.getContractFactory("Stack")) as Stack__factory;
    stack = await Stack.deploy(zeroAddress(), zeroAddress(), zeroAddress(), [token.address]);
    await stack.deployed();

    stackAsAlice = Stack__factory.connect(stack.address, alice);
    stackAsBob = Stack__factory.connect(stack.address, bob);

    await stack.setImplementation(implementation.address);

    await token.transfer(alice.address, parseEther("1000"));
    await token.transfer(bob.address, parseEther("1000"));

    tokenAsAlice = MockERC20__factory.connect(token.address, alice);
    tokenAsBob = MockERC20__factory.connect(token.address, bob);
  });

  it.only("Wallets", async () => {
    const initCodeHash = keccak256(new Wallet__factory().bytecode);
    console.log(initCodeHash);
    await stackAsAlice.createWallet();
    await stackAsBob.createWallet();
    expect(
      await stack.getWallet(alice.address),
      getCreate2Address(stack.address, keccak256Ether(["bytes"], [pack(["address"], [alice.address])]), initCodeHash)
    );
    const walletAsAlice = WalletImplementation__factory.connect(
      await stack.getWallet(alice.address),
      alice
    ) as WalletImplementation;

    await tokenAsAlice.transfer(walletAsAlice.address, parseEther("1"));
    const tx0 = await token.populateTransaction.transfer(alice.address, parseEther("1"));
    const estimatedGas = await walletAsAlice.estimateGas.execute(
      [token.address],
      [tx0.data!],
      [0],
      zeroAddress(),
      zeroAddress(),
      0
    );
    await walletAsAlice.execute([token.address], [tx0.data!], [0], zeroAddress(), zeroAddress(), estimatedGas);
    // console.log(await token.balanceOf(walletAsAlice.address));
    // console.log(tx0.gasLimit, tx0.gasPrice);
  });
});

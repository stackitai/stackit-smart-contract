import { parseEther } from "ethers/lib/utils";
import hardhat, { ethers } from "hardhat";
import { Stack, Stack__factory } from "../typechain";
import { withNetworkFile, getConfig } from "../utils";

async function main() {
  const [deployer] = await ethers.getSigners();
  const config = getConfig();
  const stack = Stack__factory.connect(config.Stack, deployer) as Stack;
  console.log(`>> Execute transaction to set implementation`);
  const estimatedGas = await stack.estimateGas.setImplementation(config.WalletImplementation);
  const tx = await stack.setImplementation(config.WalletImplementation, {
    gasLimit: estimatedGas.add(200000),
  });
  console.log(`>> returned tx hash: ${tx.hash}`);
  await tx.wait();
  console.log("✅ Done");
}

withNetworkFile(main)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

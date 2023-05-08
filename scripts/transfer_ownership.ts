import { parseEther } from "ethers/lib/utils";
import hardhat, { ethers } from "hardhat";
import { Stack, Stack__factory } from "../typechain";
import { withNetworkFile, getConfig } from "../utils";

async function main() {
  const [deployer] = await ethers.getSigners();
  const config = getConfig();
  const stack = Stack__factory.connect(config.Stack, deployer) as Stack;
  console.log(`>> Execute transaction to transfer ownership to Gnosis Safe`);
  const GNOSIS = "0xfC4CA549AbCa3E7D8Bee2DC65dB9e6e7561CcCDb";
  const estimatedGas = await stack.estimateGas.transferOwnership(GNOSIS);
  const tx = await stack.transferOwnership(GNOSIS, {
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

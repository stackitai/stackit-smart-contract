import hardhat, { ethers } from "hardhat";
import { withNetworkFile, getConfig } from "../utils";
import { keccak256 } from "ethers/lib/utils";
import { Wallet__factory } from "../typechain";

async function main() {
  const deployer = (await ethers.getSigners())[0];
  const config = getConfig();
  const initCodeHash = keccak256(new Wallet__factory().bytecode);
  console.log(initCodeHash);
}

withNetworkFile(main)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

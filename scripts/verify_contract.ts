import hardhat, { ethers } from "hardhat";
import { withNetworkFile, getConfig } from "../utils";
import { ADDRESSES_PROVIDER, ROUTER, SWAPPER, TOKENS } from "../utils/config/deployConfig";

async function main() {
  const deployer = (await ethers.getSigners())[0];
  const config = getConfig();
  {
    // Stack
    const params = [ROUTER, SWAPPER, ADDRESSES_PROVIDER, TOKENS];
    const args = {
      address: config.Stack,
      constructorArguments: Object.values(params),
    };
    await hardhat.run("verify:verify", args);
  }
}

withNetworkFile(main)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

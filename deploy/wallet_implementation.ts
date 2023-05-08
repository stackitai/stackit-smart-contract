import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { getConfig, saveAddressToConfig, withNetworkFile } from "../utils";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const config = getConfig();
  await withNetworkFile(async () => {
    await deploy("WalletImplementation", {
      from: deployer,
      args: [],
      log: true,
      deterministicDeployment: false,
    });

    saveAddressToConfig("WalletImplementation", (await deployments.get("WalletImplementation")).address);
  });
};

export default func;
func.tags = ["DeployWalletImplementation"];

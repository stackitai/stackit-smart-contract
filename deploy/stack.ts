import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { getConfig, saveAddressToConfig, withNetworkFile } from "../utils";
import { ADDRESSES_PROVIDER, ROUTER, SWAPPER, TOKENS } from "../utils/config/deployConfig";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const config = getConfig();
  await withNetworkFile(async () => {
    await deploy("Stack", {
      from: deployer,
      args: [ROUTER, SWAPPER, ADDRESSES_PROVIDER, TOKENS],
      log: true,
      deterministicDeployment: false,
    });

    saveAddressToConfig("Stack", (await deployments.get("Stack")).address);
  });
};

export default func;
func.tags = ["DeployStack"];

import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-web3";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-typechain";
import "hardhat-deploy";
import "hardhat-log-remover";
import "@nomiclabs/hardhat-etherscan";
import "hardhat-contract-sizer";

export default {
  etherscan: {
    apiKey: "8HQ6CUVT1H4BZFU42NUDSE5BD5MDGGYTMQ",
  },
  defaultNetwork: "polygon_mainnet",
  networks: {
    localhost: {
      url: "http://localhost:8545",
      accounts: [],
    },
    ftm_testnet: {
      url: "https://fantom-testnet.public.blastapi.io",
      accounts: [process.env.PRIVATE_KEY],
    },
    polygon_mainnet: {
      url: "https://polygon-rpc.com",
      accounts: [process.env.PRIVATE_KEY],
      gasPrice: 260000000000,
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  paths: {
    sources: "./contracts",
    tests: "./tests",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  typechain: {
    outDir: "./typechain",
    target: process.env.TYPECHAIN_TARGET || "ethers-v5",
  },
  mocha: {
    timeout: 500000,
  },
};

#!/bin/bash#

# rm -rf .openzeppelin
# rm -rf artifacts
# rm -rf cache
# rm -rf deployments
# rm -rf typechain

# npx hardhat compile
# npx hardhat deploy --no-compile --tags DeployStack
# npx hardhat deploy --no-compile --tags DeployWalletImplementation
npx hardhat run --no-compile ./scripts/set_implementation.ts
npx hardhat run --no-compile ./scripts/transfer_ownership.ts
npx hardhat run --no-compile ./scripts/verify_contract.ts
npx hardhat run --no-compile ./scripts/get_init_code_hash.ts
import { ethers } from "hardhat";

export const getBlockNumberNow = async (addNumber: number): Promise<number> => {
  return Math.ceil((await ethers.provider.getBlockNumber()) + addNumber);
};

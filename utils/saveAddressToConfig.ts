import { getConfig, IKeyOfConfig } from ".";
import fs from "fs";
import { DeployResult } from "hardhat-deploy/types";

export const saveAddressToConfig = (key: IKeyOfConfig | [IKeyOfConfig, any], value: string) => {
  const config = { ...getConfig() };
  console.log({ key, value });
  if (typeof key === "string") {
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    config[key] = value;
  } else {
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    config[key[0]][key[1]] = value;
  }

  const configString = JSON.stringify(config);
  fs.writeFileSync(__dirname + "/config/dev.json", configString);
};

export const handlePromiseSaveAddressToConfig = (key: IKeyOfConfig | [IKeyOfConfig, any]) => (result: DeployResult) =>
  saveAddressToConfig(key, result.address);

export const saveBatchAddressToConfig = (data: Array<[IKeyOfConfig | [IKeyOfConfig, any], string]>) => {
  const config = { ...getConfig() };

  data.forEach(([key, value]) => {
    console.log({ key, value });
    if (typeof key === "string") {
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore
      config[key] = value;
    } else {
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore
      config[key[0]][key[1]] = value;
    }
  });
  const configString = JSON.stringify(config);
  fs.writeFileSync(__dirname + "/config/dev.json", configString);
};

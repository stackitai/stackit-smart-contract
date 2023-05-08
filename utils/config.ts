import DevelopConfig from "./config/dev.json";

export type IConfig = typeof DevelopConfig;
export type IKeyOfConfig = keyof IConfig;
export function getConfig(): IConfig {
  const config = DevelopConfig;
  return config;
}

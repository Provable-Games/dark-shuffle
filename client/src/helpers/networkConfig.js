import manifest_mainnet from "../../manifest_mainnet.json";
import { getContractByName } from "@dojoengine/core";

export const NETWORKS = {
  SN_MAIN: {
    chainId: "SN_MAIN",
    namespace: "ds_v1_2_1",
    manifest: manifest_mainnet,
    slot: "pg-mainnet-10",
    rpcUrl: "https://api.cartridge.gg/x/starknet/mainnet/rpc/v0_9",
    torii: "https://api.cartridge.gg/x/pg-mainnet-10/torii",
    denshokan: "0x036017e69d21d6d8c13e266eabb73ef1f1d02722d86bdcabe5f168f8e549d3cd",
  },
};

export function getNetworkConfig(networkKey) {
  const network = NETWORKS[networkKey];
  if (!network) throw new Error(`Network ${networkKey} not found`);

  const policies = undefined;

  return {
    chainId: network.chainId,
    namespace: network.namespace,
    manifest: network.manifest,
    slot: network.slot,
    preset: "dark-shuffle",
    policies: policies,
    rpcUrl: network.rpcUrl,
    toriiUrl: network.torii,
    chains: [{ rpcUrl: network.rpcUrl }],
    denshokan: network.denshokan,
  };
}
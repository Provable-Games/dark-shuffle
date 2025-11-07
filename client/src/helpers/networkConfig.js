import manifest_mainnet from "../../manifest_mainnet.json";

export const NETWORKS = {
  SN_MAIN: {
    chainId: "SN_MAIN",
    namespace: "ds_v1_2_0",
    manifest: manifest_mainnet,
    slot: "pg-mainnet-10",
    rpcUrl: "https://api.cartridge.gg/x/starknet/mainnet/rpc/v0_9",
    torii: "https://api.cartridge.gg/x/pg-mainnet-10/torii",
  },
};

export function getNetworkConfig(networkKey) {
  const network = NETWORKS[networkKey];
  if (!network) throw new Error(`Network ${networkKey} not found`);

  return {
    chainId: network.chainId,
    namespace: network.namespace,
    manifest: network.manifest,
    slot: network.slot,
    preset: "dark-shuffle",
    policies: undefined,
    rpcUrl: network.rpcUrl,
    toriiUrl: network.torii,
    chains: [{ rpcUrl: network.rpcUrl }],
  };
}
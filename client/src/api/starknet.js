import { useDynamicConnector } from "@/contexts/starknet";
import { NETWORKS } from "@/helpers/networkConfig";
import { parseBalances } from "@/helpers/utilities";
import { hexToAscii } from "@dojoengine/utils";
import { useAccount } from "@starknet-react/core";
import { num } from "starknet";

export const useStarknetApi = () => {
  const { currentNetworkConfig } = useDynamicConnector();
  const { address } = useAccount();

  const getTokenBalances = async (tokens) => {
    const calls = tokens.map((token, i) => ({
      id: i + 1,
      jsonrpc: "2.0",
      method: "starknet_call",
      params: [
        {
          contract_address: token.address,
          entry_point_selector: "0x2e4263afad30923c891518314c3c95dbe830a16874e8abc5777a9a20b54c76e",
          calldata: [address]
        },
        "latest"
      ]
    }));

    const response = await fetch(NETWORKS[import.meta.env.VITE_PUBLIC_CHAIN].rpcUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(calls),
    });

    const data = await response.json();

    return parseBalances(data || [], tokens);
  }

  const getTokenMetadata = async (tokenId) => {
    try {
      const response = await fetch(currentNetworkConfig.rpcUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify([
          {
            jsonrpc: "2.0",
            method: "starknet_call",
            params: [
              {
                contract_address: currentNetworkConfig.denshokan,
                entry_point_selector: "0x20d82cc6889093dce20d92fc9daeda4498c9b99ae798fc2a6f4757e38fb1729",
                calldata: [num.toHex(tokenId)],
              },
              "latest",
            ],
            id: 0,
          },
          {
            jsonrpc: "2.0",
            method: "starknet_call",
            params: [
              {
                contract_address: currentNetworkConfig.denshokan,
                entry_point_selector: "0x170ac5a9fd747db6517bea85af33fcc77a61d4442c966b646a41fdf9ecca233",
                calldata: [num.toHex(tokenId)],
              },
              "latest",
            ],
            id: 1,
          }
        ]),
      });

      const data = await response.json();
      if (!data[0]?.result) return null;

      let tokenMetadata = {
        id: tokenId,
        tokenId,
        playerName: hexToAscii(data[1].result[0]),
        mintedAt: parseInt(data[0].result[1], 16) * 1000,
        settingsId: parseInt(data[0].result[2]),
        expires_at: parseInt(data[0].result[3], 16) * 1000,
        available_at: parseInt(data[0].result[4], 16) * 1000,
        minted_by: data[0].result[5],
      }

      return tokenMetadata;
    } catch (error) {
      console.log('error', error)
    }

    return null;
  }

  return {
    getTokenBalances,
    getTokenMetadata,
  };
};

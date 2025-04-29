import { CallData } from "starknet";
import { dojoConfig } from "../../dojo.config";
import { getContractByName } from "@dojoengine/core";

const GAME_ADDRESS = getContractByName(dojoConfig.manifest, dojoConfig.namespace, "game_systems")?.address

export const fetchBalances = async (account, lordsContract) => {
  const lordsBalanceResult = await lordsContract?.call(
    "balance_of",
    CallData.compile({ account })
  );

  return {
    lords: lordsBalanceResult ?? BigInt(0),
  };
};

export const fetchQuestTarget = async (questId) => {
  try {
    const response = await fetch(dojoConfig.rpcUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        jsonrpc: "2.0",
        method: "starknet_call",
        params: [
          {
            contract_address: dojoConfig.eternumQuestAddress,
            entry_point_selector: "0xb6164a78459165f0920db46e2adcae170df7e54c223fe9c265345b5dc36149",
            calldata: [questId.toString(16), GAME_ADDRESS],
          },
          "pending",
        ],
        id: 0,
      }),
    });

    const data = await response.json();
    return parseInt(data?.result[0], 16);
  } catch (error) {
    console.log('error', error)
  }

  return null;
};

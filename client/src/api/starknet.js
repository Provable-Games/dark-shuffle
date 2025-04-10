import { CallData } from "starknet";
import { dojoConfig } from "../../dojo.config";

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
            entry_point_selector: "0xb0d944377304e5d17e57a0404b4c1714845736851cfe18cc171a33868091be",
            calldata: [questId.toString(16), "0x0"],
          },
          "pending",
        ],
        id: 0,
      }),
    });

    const data = await response.json();
    return data?.result[0].target_score;
  } catch (error) {
    console.log('error', error)
  }

  return 300;
};

import { CallData } from "starknet";
import { dojoConfig } from "../../dojo.config";
import { getContractByName } from "@dojoengine/core";
import { hexToAscii } from "@dojoengine/utils";

export const fetchBalances = async (account, ethContract, lordsContract) => {
  const ethResult = await ethContract?.call(
    "balanceOf",
    CallData.compile({ account })
  );

  const lordsBalanceResult = await lordsContract?.call(
    "balance_of",
    CallData.compile({ account })
  );

  return {
    eth: ethResult?.balance?.low ?? BigInt(0),
    lords: lordsBalanceResult ?? BigInt(0),
  };
};
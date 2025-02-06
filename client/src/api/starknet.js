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

export const fetchDarkShuffleGameTokens = async (player_address, limit, page, active) => {
  try {
    const tokens_response = await fetch(dojoConfig.rpcUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        jsonrpc: "2.0",
        method: "starknet_call",
        params: [
          {
            contract_address: getContractByName(dojoConfig.manifest, dojoConfig.namespace, "game_systems")?.address,
            entry_point_selector: "0x13237784c922d0ad2a5c12f4c37d461e65eacc9e208fe81986b1fef6cb916a",
            calldata: [player_address, `0x${limit.toString(16)}`, '0x0', `0x${page.toString(16)}`, '0x0', `0x${active.toString(16)}`],
          },
          "pending",
        ],
        id: 0,
      }),
    });

    const data = await tokens_response.json();

    let games = [];

    for (let i = 1; i < data.result.length; i += 10) {
      const game = data.result.slice(i, i + 10);

      games.push({
        id: parseInt(game[0], 16),
        season: parseInt(game[1], 16),
        hp: parseInt(game[2], 16),
        xp: parseInt(game[3], 16),
        state: parseInt(game[9], 16),
        player_name: "test",
      });
    }

    console.log('games', games)
    return games
  } catch (error) {
    console.log(error);
  }
};

export const fetchGameSettings = async (game_id) => {
  try {
    const settings_response = await fetch(dojoConfig.rpcUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        jsonrpc: "2.0",
        method: "starknet_call",
        params: [
          {
            contract_address: getContractByName(dojoConfig.manifest, dojoConfig.namespace, "game_systems")?.address,
            entry_point_selector: "0x200edeb3a2866ed609c06da9c90fad20a0d4f3d36ecf7928a003a58188758a0",
            calldata: [`0x${game_id.toString(16)}`],
          },
          "pending",
        ],
        id: 1,
      }),
    });

    const data = await settings_response.json();

    if (!data.result) {
      return null
    }

    return {
      settings_id: parseInt(data.result[0], 16),
      start_health: parseInt(data.result[1], 16),
      start_energy: parseInt(data.result[2], 16),
      start_hand_size: parseInt(data.result[3], 16),
      draft_size: parseInt(data.result[4], 16),
      max_energy: parseInt(data.result[5], 16),
      max_hand_size: parseInt(data.result[6], 16),
      include_spells: parseInt(data.result[7], 16),
    }
  } catch (error) {
    console.log(error);
  }
};
import { CallData } from "starknet";
import { dojoConfig } from "../../dojo.config";

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

export const getGameTokens = async (owner) => {
  const BLAST_URL = import.meta.env.VITE_PUBLIC_BLAST_API;

  const recursiveFetchTokens = async (tokenList, nextPageKey) => {
    let url = `${BLAST_URL}/builder/getWalletNFTs?contractAddress=${dojoConfig.gameTokenAddress}&walletAddress=${owner}&pageSize=100`

    if (nextPageKey) {
      url += `&pageKey=${nextPageKey}`
    }

    try {
      const response = await fetch(url, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
      });

      const data = await response.json();
      tokenList = tokenList.concat(data.nfts)

      if (data.nextPageKey) {
        return recursiveFetchTokens(tokenList, data.nextPageKey)
      }
    } catch (ex) {
      console.log('error fetching tokens', ex)
      await new Promise(resolve => setTimeout(resolve, 1000));
      return recursiveFetchTokens(tokenList, nextPageKey);
    }

    return tokenList
  }

  let tokens = await recursiveFetchTokens([], null)
  console.log('tokens', tokens)
  return tokens.map(token => token.tokenId)
};
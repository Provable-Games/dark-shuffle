import { DojoProvider } from "@dojoengine/core";
import { num } from "starknet";
import manifest from "../../manifest_tournaments.json";

class TournamentSDK {
  constructor(rpcUrl) {
    this.provider = new DojoProvider(manifest, rpcUrl);
    this.contractAddress = manifest.contracts[0]?.address;
    this.contractName = manifest.contracts[0]?.tag?.split("-")[1];
    this.namespace = manifest.contracts[0]?.tag?.split("-")[0];
  }

  async execute(account, txs) {
    if (!account) {
      throw new Error("No account provided");
    }

    try {
      const { transaction_hash } = await this.provider.execute(account, txs, this.namespace, { version: "1" });
      return account.waitForTransaction(transaction_hash, { retryInterval: 500 });
    } catch (error) {
      console.error('Error executing transaction:', error);
    }
  }

  async getTournamentDetails(tournamentId) {
    const tournamentDetails = await this.provider.call(this.namespace, {
      contractName: this.contractName,
      entrypoint: "tournament",
      calldata: [tournamentId]
    });
    return tournamentDetails;
  }

  async getTournamentLeaderboard(tournamentId) {
    const leaderboard = await this.provider.call(this.namespace, {
      contractName: this.contractName,
      entrypoint: "get_leaderboard",
      calldata: [tournamentId]
    });
    return leaderboard;
  }

  async enterTournament({ account, tournamentId, playerName }) {
    const tournamentDetails = await this.getTournamentDetails(tournamentId)
    if (!tournamentDetails.created_by) {
      throw new Error("Tournament not found");
    }

    let txs = []
    if (tournamentDetails.entry_fee.Some) {
      txs.push({
        contractAddress: num.toHex(tournamentDetails.entry_fee.Some.token_address),
        entrypoint: "approve",
        calldata: [this.contractAddress, tournamentDetails.entry_fee.Some.amount, "0"]
      })
    }

    txs.push({
      contractName: this.contractName,
      entrypoint: "enter_tournament",
      calldata: [
        tournamentId,
        '0x' + playerName.split('').map(char => char.charCodeAt(0).toString(16)).join(''),
        account.address,
        1
      ]
    })

    return this.execute(account, txs);
  }

  async submitScore({ account, tournamentId, tokenId, position }) {
    return this.execute(account, [
      {
        contractName: this.contractName,
        entrypoint: "submit_score",
        calldata: [tournamentId, tokenId, position]
      }
    ]);
  }

  async submitScores({ account, tournamentId, scores }) {
    let txs = []
    for (let i = 0; i < scores.length; i++) {
      txs.push({
        contractName: this.contractName,
        entrypoint: "submit_score",
        calldata: [tournamentId, scores[i], i + 1]
      })
    }
    return this.execute(account, txs);
  }

  async distributePrizes({ account, tournamentId }) {
    const leaderboard = await this.getTournamentLeaderboard(tournamentId)

    let txs = []
    for (let position = 1; position <= leaderboard.length; position++) {
      txs.push({
        contractName: this.contractName,
        entrypoint: "claim_prize",
        calldata: [tournamentId, 0, 2, position]
      })
    }
    return this.execute(account, txs);
  }
}

export default TournamentSDK;
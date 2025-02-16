import { DojoProvider } from "@dojoengine/core";
import { num } from "starknet";
import manifest from "../../manifest_tournaments.json";

class TournamentSDK {
  constructor(rpcUrl) {
    this.namespace = "tournaments"
    this.contractName = "tournament_mock"
    this.contractAddress = "0x042f50523bcbd31e9a50b2928debb4647c4060d500b5f45792df297188206323"
    this.provider = new DojoProvider(manifest, rpcUrl);
  }

  async execute(account, txs) {
    if (!account) {
      throw new Error("No account provided");
    }

    try {
      const { transaction_hash } = await this.provider.execute(account, txs, this.namespace, { version: "1" });
      return account.waitForTransaction(transaction_hash);
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

  async enterTournament({ account, tournamentId, playerName }) {
    const tournamentDetails = await this.getTournamentDetails(tournamentId)
    if (!tournamentDetails.creator) {
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

  async claimPrize({ account, tournamentId, prizeType }) {
    return this.execute(account, [
      {
        contractName: this.contractName,
        entrypoint: "claim_prize",
        calldata: [tournamentId, prizeType]
      }
    ]);
  }
}

export default TournamentSDK;
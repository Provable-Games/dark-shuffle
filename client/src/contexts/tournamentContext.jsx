import { useAccount, useConnect } from '@starknet-react/core';
import React, { createContext, useContext, useEffect, useState } from 'react';
import { dojoConfig } from '../../dojo.config';
import { getActiveTournaments, getTournament } from '../api/indexer';
import TournamentSDK from '../sdk/tournaments';
import { DojoContext } from './dojoContext';
import { translateEvent } from '../helpers/events';
import { hexToAscii } from '@dojoengine/utils';

// Create a context
const TournamentContext = createContext();
const tournamentSDK = new TournamentSDK(dojoConfig.rpcUrl)

// Create a provider component
export const TournamentProvider = ({ children }) => {
  const dojo = useContext(DojoContext)
  const { account } = useAccount()
  const { connect, connectors } = useConnect();

  const [season, setSeason] = useState({});
  const [tournaments, setTournaments] = useState([])

  async function fetchSeason() {
    const data = await getTournament(dojoConfig.seasonTournamentId)
    let entryFee = parseInt(data.tournament.entry_fee?.Some?.amount || 0, 16)

    setSeason({
      tournamentId: dojoConfig.seasonTournamentId,
      start: parseInt(data.tournament.schedule?.game?.start || 0, 16),
      end: parseInt(data.tournament.schedule?.game?.end || 0, 16),
      entryFee: entryFee,
      rewardPool: entryFee * data.entryCount,
      submissionPeriod: parseInt(data.tournament.schedule?.submission_period || 0, 16)
    })
  }

  async function fetchTournaments() {
    const data = await getActiveTournaments()

    setTournaments(data.map(tournament => ({
      id: parseInt(tournament.id, 16),
      name: hexToAscii(tournament.metadata?.name || ""),
      description: tournament.metadata?.description || "",
      start: parseInt(tournament.schedule?.game?.start || 0, 16),
      end: parseInt(tournament.schedule?.game?.end || 0, 16),
      entryFee: parseInt(tournament.entry_fee?.Some?.amount || 0, 16),
      submissionPeriod: parseInt(tournament.schedule?.submission_period || 0, 16)
    })))
  }

  useEffect(() => {
    fetchSeason()
    fetchTournaments()
  }, [])

  const enterTournament = async (tournamentId) => {
    if (!account) {
      connect({ connector: connectors.find(conn => conn.id === "controller") })
      return
    }

    const receipt = await tournamentSDK.enterTournament({ account, tournamentId, playerName: dojo.playerName })

    const translatedEvents = receipt.events.map(event => translateEvent(event)).filter(Boolean)
    const tokenMetadata = translatedEvents.find(e => e.componentName === 'TokenMetadata')
    return tokenMetadata
  }

  return (
    <TournamentContext.Provider value={{
      season,
      tournaments,

      actions: {
        enterTournament,
      }
    }}>
      {children}
    </TournamentContext.Provider>
  );
};

export const useTournament = () => {
  return useContext(TournamentContext);
};


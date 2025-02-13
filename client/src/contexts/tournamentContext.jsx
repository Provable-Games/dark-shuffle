import { useAccount, useConnect } from '@starknet-react/core';
import React, { createContext, useContext, useEffect, useState } from 'react';
import { dojoConfig } from '../../dojo.config';
import { getTournament } from '../api/indexer';
import TournamentSDK from '../sdk/tournaments';
import { DojoContext } from './dojoContext';
import { translateEvent } from '../helpers/events';

// Create a context
const TournamentContext = createContext();
const tournamentSDK = new TournamentSDK(dojoConfig.rpcUrl)

// Create a provider component
export const TournamentProvider = ({ children }) => {
  const dojo = useContext(DojoContext)
  const { account } = useAccount()
  const { connect, connectors } = useConnect();

  const [season, setSeason] = useState({});

  useEffect(() => {
    async function fetchSeason() {
      const data = await getTournament(dojoConfig.seasonTournamentId)
      let entryFee = parseInt(data.tournament.entry_fee?.Some?.amount || 0, 16)

      setSeason({
        tournamentId: dojoConfig.seasonTournamentId,
        start: parseInt(data.tournament.schedule?.game?.start || 0, 16),
        end: parseInt(data.tournament.schedule?.game?.end || 0, 16),
        entryFee: entryFee,
        rewardPool: entryFee * data.entryCount,
      })
    }
  
    fetchSeason()
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


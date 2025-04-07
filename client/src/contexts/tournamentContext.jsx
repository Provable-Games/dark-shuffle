import React, { createContext, useContext, useEffect, useState } from 'react';
import { dojoConfig } from '../../dojo.config';
import { getActiveTournaments, getTournament } from '../api/indexer';

// Create a context
const TournamentContext = createContext();

// Create a provider component
export const TournamentProvider = ({ children }) => {
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
      entryCount: data.entryCount,
      rewardPool: entryFee * data.entryCount,
      distribution: data.tournament.entry_fee?.Some?.distribution || [],
      submissionPeriod: parseInt(data.tournament.schedule?.submission_duration || 0, 16),
      leaderboard: data.leaderboard.map(tokenId => Number(tokenId))
    })
  }

  async function fetchTournaments() {
    const data = await getActiveTournaments()
    setTournaments(data)
  }

  useEffect(() => {
    fetchSeason()
    fetchTournaments()
  }, [])

  return (
    <TournamentContext.Provider value={{
      season,
      tournaments,
    }}>
      {children}
    </TournamentContext.Provider>
  );
};

export const useTournament = () => {
  return useContext(TournamentContext);
};


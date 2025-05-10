import React, { createContext, useContext, useEffect, useState } from 'react';
import { dojoConfig } from '../../dojo.config';
import { getActiveTournaments, getTournament } from '../api/indexer';

// Create a context
const TournamentContext = createContext();

// Create a provider component
export const TournamentProvider = ({ children }) => {
  const [season, setSeason] = useState({});
  const [tournaments, setTournaments] = useState([])

  async function fetchTournaments() {
    const data = await getActiveTournaments()
    setTournaments(data)
  }

  useEffect(() => {
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


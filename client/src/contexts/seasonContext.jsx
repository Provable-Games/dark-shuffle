import React, { createContext, useContext, useEffect, useState } from 'react';
import { dojoConfig } from '../../dojo.config';
import { getTournament, getSettings } from '../api/indexer';

// Create a context
const SeasonContext = createContext();

// Create a provider component
export const SeasonProvider = ({ children }) => {
  const [values, setValues] = useState({});
  const [settings, setSettings] = useState({});

  useEffect(() => {
    async function fetchSeason() {
      const tournament = await getTournament(dojoConfig.tournamentId)

      setValues({
        settingsId: tournament.game_config.settings_id,
        end: parseInt(tournament.schedule.end, 16),
        start: parseInt(tournament.schedule.start, 16),
        entryFee: parseInt(tournament.entry_fee.amount, 16),
        rewardPool: 0
      })

      const settings = await getSettings(tournament.game_config.settings_id)
      setSettings(settings)
    }

    fetchSeason()
  }, [])

  return (
    <SeasonContext.Provider value={{
      values,
      settings
    }}>
      {children}
    </SeasonContext.Provider>
  );
};

export const useSeason = () => {
  return useContext(SeasonContext);
};


import React, { createContext, useContext, useEffect, useState } from 'react';
import { dojoConfig } from '../../dojo.config';
import { getSeason, getSettings } from '../api/indexer';

// Create a context
const SeasonContext = createContext();

// Create a provider component
export const SeasonProvider = ({ children }) => {
  const [values, setValues] = useState({});
  const [settings, setSettings] = useState({});

  useEffect(() => {
    async function fetchSeason() {
      const season = await getSeason(dojoConfig.seasonId)

      setValues({
        settingsId: season.settings_id,
        end: parseInt(season.end, 16),
        start: parseInt(season.start, 16),
        entryFee: parseInt(season.entry_amount, 16),
        rewardPool: parseInt(season.reward_pool, 16),
      })

      const settings = await getSettings(season.settings_id)
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


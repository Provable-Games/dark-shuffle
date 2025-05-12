import { LoadingButton } from '@mui/lab';
import { Box, Button, CircularProgress, Dialog, Divider, TextField, Typography } from '@mui/material';
import { useAccount, useConnect } from '@starknet-react/core';
import { motion } from "framer-motion";
import React, { useContext, useEffect, useState } from 'react';
import Scrollbars from 'react-custom-scrollbars';
import { getRecommendedSettings, getSettingsList } from '../../api/indexer';
import { GameContext } from '../../contexts/gameContext';
import { fadeVariant } from "../../helpers/variants";
import GameSettings from './gameSettings';

function GameSettingsList(props) {
  const { open, close } = props

  const gameContext = useContext(GameContext)
  const { account, address } = useAccount()
  const { connect, connectors } = useConnect();

  const [selectedSettings, setselectedSettings] = useState()

  const [loading, setLoading] = useState(false)
  const [tab, setTab] = useState('recommended')
  const [gameSettings, openGameSettings] = useState(false)
  const [settingsList, setSettingsList] = useState([])
  const [search, setSearch] = useState('')

  async function fetchSettings() {
    if (tab === 'search' && !search) {
      setSettingsList([])
      return
    }

    setLoading(true)

    if (tab === 'recommended') {
      const settings = await getRecommendedSettings()
      setSettingsList(settings ?? [])
    } else {
      const settings = await getSettingsList(tab === 'my' ? address : null, [search])
      setSettingsList(settings ?? [])
    }

    setLoading(false)
  }

  useEffect(() => {
    if (tab === 'recommended') {
      setSettingsList(gameContext.recommendedSettings)
    } else {
      fetchSettings()
    }
  }, [tab, search, gameContext.recommendedSettings])

  useEffect(() => {
    if (settingsList.length > 0) {
      setselectedSettings(settingsList[0])
    }
  }, [settingsList])

  const startNewGame = async () => {
    if (!account) {
      connect({ connector: connectors.find(conn => conn.id === "controller") })
      return
    }

    close();
    gameContext.actions.mintFreeGame(selectedSettings.settings_id)
  }

  function renderSettingsOverview(settings) {
    return <Box sx={[styles.settingsContainer, { opacity: selectedSettings?.settings_id === settings.settings_id ? 1 : 0.8 }]}
      border={selectedSettings?.settings_id === settings.settings_id ? '1px solid #f59100' : '1px solid rgba(255, 255, 255, 0.3)'}
      onClick={() => setselectedSettings(settings)}
    >
      <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <Typography color='primary' variant='h6'>
          {settings.name}
        </Typography>

        <Typography color='rgba(255, 255, 255, 0.5)' variant='caption'>
          #{settings.settings_id}
        </Typography>
      </Box>

      <Typography color='secondary' sx={{ fontSize: '13px' }}>
        {settings.description}
      </Typography>
    </Box >
  }

  return (
    <Dialog
      open={open}
      onClose={() => close()}
      maxWidth={'lg'}
      PaperProps={{
        sx: { background: 'rgba(0, 0, 0, 1)', border: '1px solid #FFE97F', maxWidth: '98vw' }
      }}
    >
      <Box sx={styles.dialogContainer}>

        <motion.div variants={fadeVariant} exit='exit' animate='enter'>
          <Box sx={styles.container}>

            <Box display={'flex'} alignItems={'center'} justifyContent={'space-between'}>
              <Typography variant='h5' textAlign={'center'} color='primary'>
                Game Settings
              </Typography>

              <Button variant='outlined' color='primary' size='small' onClick={() => openGameSettings('create')}>
                + Create Settings
              </Button>
            </Box>

            <Divider />

            <Box sx={styles.settingsListContainer}>
              <Box sx={{ display: 'flex', width: '100%', alignItems: 'center', justifyContent: 'space-between' }}>
                <Box sx={{ display: 'flex', gap: 1 }}>
                  <Button variant='outlined' size='small' sx={{ opacity: tab === 'recommended' ? 1 : 0.8 }} color={tab === 'recommended' ? 'primary' : 'secondary'} onClick={() => setTab('recommended')}>
                    Recommended
                  </Button>

                  <Button variant='outlined' size='small' sx={{ opacity: tab === 'my' ? 1 : 0.8 }} color={tab === 'my' ? 'primary' : 'secondary'} onClick={() => setTab('my')}>
                    My Settings
                  </Button>

                  <Button variant='outlined' size='small' sx={{ opacity: tab === 'search' ? 1 : 0.8, width: '105px' }} color={tab === 'search' ? 'primary' : 'secondary'} onClick={() => setTab('search')}>
                    Search
                  </Button>
                </Box>
              </Box>



              <Scrollbars style={{ width: '100%', height: '340px' }}>
                {tab === 'search' && <Box mb={1} pt={1}>
                  <TextField
                    type='text'
                    placeholder="Enter settings id"
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    fullWidth
                    size='small'
                  />
                </Box>}

                {loading && <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
                  <CircularProgress />
                </Box>}

                {!loading && React.Children.toArray(
                  settingsList.map(settings => renderSettingsOverview(settings))
                )}
              </Scrollbars>
            </Box>

            <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center' }}>
              <Button color='warning' variant='outlined' size='large' onClick={() => openGameSettings('view')}
                disabled={!selectedSettings}
              >
                View Settings
              </Button>

              <LoadingButton variant='outlined' size='large' sx={{ width: '140px' }}
                disabled={!selectedSettings}
                onClick={() => startNewGame()}
              >
                Play
              </LoadingButton>
            </Box>

          </Box>
        </motion.div>

      </Box>

      {gameSettings && <GameSettings
        settingsId={selectedSettings?.settings_id}
        view={gameSettings === 'view'}
        close={() => openGameSettings(false)}
        closeList={() => close()}
        refetch={() => {
          if (tab === 'my') {
            fetchSettings()
          } else {
            setTab('my')
          }
        }} />}
    </Dialog>
  )
}

export default GameSettingsList

const styles = {
  dialogContainer: {
    display: 'flex',
    flexDirection: 'column',
    boxSizing: 'border-box',
    py: 2,
    px: 3,
    width: '100%',
    maxWidth: '500px',
    overflow: 'hidden'
  },
  container: {
    boxSizing: 'border-box',
    width: '100%',
    display: 'flex',
    flexDirection: 'column',
    gap: 1.5
  },
  settingsContainer: {
    width: '100%',
    display: 'flex',
    flexDirection: 'column',
    borderRadius: '2px',
    px: 2,
    py: 1,
    cursor: 'pointer',
    boxSizing: 'border-box',
    mb: 1
  },
  settingsListContainer: {
    width: '340px',
    maxWidth: '100%',
    minHeight: '200px',
    display: 'flex',
    flexDirection: 'column',
    gap: 1,
  },
}
import FavoriteIcon from '@mui/icons-material/Favorite';
import { LoadingButton } from '@mui/lab';
import { Box, Button, CircularProgress, Dialog, Typography } from '@mui/material';
import { motion } from "framer-motion";
import { useSnackbar } from 'notistack';
import React, { useContext, useEffect, useState } from 'react';
import Scrollbars from 'react-custom-scrollbars';
import { getSettingsList } from '../../api/indexer';
import { GameContext } from '../../contexts/gameContext';
import { fadeVariant } from "../../helpers/variants";
import GameSettings from './gameSettings';
import { hexToAscii } from '@dojoengine/utils';

function GameSettingsList(props) {
  const { open, close } = props

  const gameContext = useContext(GameContext)
  const { enqueueSnackbar } = useSnackbar()

  const [selectedSettings, setselectedSettings] = useState()

  const [loading, setLoading] = useState(true)
  const [gameSettings, openGameSettings] = useState(false)
  const [settingsList, setSettingsList] = useState([])
  const [minting, setMinting] = useState(false)

  useEffect(() => {
    async function fetchSettings() {
      setLoading(true)

      const settings = await getSettingsList()
      setSettingsList(settings ?? [])

      setLoading(false)
    }

    fetchSettings()
  }, [])

  const mintGame = async () => {
    setMinting(true)

    const res = await gameContext.actions.mintFreeGame(selectedSettings.settings_id)

    if (res) {
      enqueueSnackbar('Game minted with settings #' + selectedSettings.settings_id, { variant: 'success' })
      close(false)
    } else {
      enqueueSnackbar('Failed to mint game', { variant: 'error' })
    }

    setMinting(false)
  }

  function renderSettingsOverview(settings) {
    return <Box sx={[styles.settingsContainer, { opacity: selectedSettings?.settings_id === settings.settings_id ? 1 : 0.8 }]}
      border={selectedSettings?.settings_id === settings.settings_id ? '1px solid #f59100' : '1px solid rgba(255, 255, 255, 0.3)'}
      onClick={() => setselectedSettings(settings)}
    >
      <Typography color='primary' variant='h6'>
        {hexToAscii(settings.name)}
      </Typography>

      <Typography color='secondary'>
        {settings.description}
      </Typography>
    </Box >
  }

  return (
    <Dialog
      open={open}
      onClose={() => close(false)}
      maxWidth={'lg'}
      PaperProps={{
        sx: { background: 'rgba(0, 0, 0, 1)', border: '1px solid #FFE97F' }
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

            <Box sx={styles.settingsListContainer}>
              {loading && <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '340px' }}>
                <CircularProgress />
              </Box>}

              {!loading && <Scrollbars style={{ width: '100%', height: '340px' }}>
                {React.Children.toArray(
                  settingsList.map(settings => renderSettingsOverview(settings))
                )}
              </Scrollbars>}
            </Box>

            <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center' }}>
              <Button color='warning' variant='outlined' size='large' onClick={() => openGameSettings('view')}
                disabled={!selectedSettings}
              >
                View Settings
              </Button>

              <LoadingButton variant='outlined' size='large' sx={{ width: '140px' }}
                disabled={!selectedSettings}
                loading={minting}
                onClick={() => mintGame()}
              >
                Mint Game
              </LoadingButton>
            </Box>

          </Box>
        </motion.div>

      </Box>

      {gameSettings && <GameSettings settingsId={selectedSettings?.settings_id} view={gameSettings === 'view'} close={() => openGameSettings(false)} />}
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
    gap: 1,
    cursor: 'pointer',
    boxSizing: 'border-box',
    mb: 1
  },
  settingsListContainer: {
    width: '370px',
    maxWidth: '100%',
    minHeight: '200px',
    display: 'flex',
    flexDirection: 'column',
    gap: 1,
  },
}
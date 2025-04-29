import { hexToAscii } from '@dojoengine/utils';
import AccessTimeIcon from '@mui/icons-material/AccessTime';
import FavoriteIcon from '@mui/icons-material/Favorite';
import WatchIcon from '@mui/icons-material/Watch';
import { Box, Button, CircularProgress, Dialog, Typography } from '@mui/material';
import { motion } from "framer-motion";
import React, { useContext, useEffect, useState } from 'react';
import Scrollbars from 'react-custom-scrollbars';
import { getGameTokens, getSettingsMetadata, populateGameTokens } from '../../api/indexer';
import { fetchQuestTarget } from '../../api/starknet';
import logo from '../../assets/images/logo.svg';
import { GameContext } from '../../contexts/gameContext';
import { useTournament } from '../../contexts/tournamentContext';
import { fadeVariant } from "../../helpers/variants";
import GameSettings from './gameSettings';

function GameTokens(props) {
  const gameContext = useContext(GameContext)
  const { tournaments } = useTournament()
  const { open, close, address } = props

  const [games, setGames] = useState([])
  const [selectedGame, setSelectedGame] = useState()

  const [active, showActive] = useState(true)
  const [loading, setLoading] = useState(true)
  const [gameSettings, openGameSettings] = useState(false)

  useEffect(() => {
    async function fetchGames() {
      setLoading(true)

      const gameTokenIds = await getGameTokens(address)
      let games = await populateGameTokens(gameTokenIds)
      let settingsMetadata = await getSettingsMetadata(games.map(game => game.settingsId))

      games = await Promise.all(games.map(async (game) => ({
        ...game,
        settingsMetadata: settingsMetadata.find(metadata => metadata.settings_id === game.settingsId),
        tournament: tournaments?.find(tournament => tournament.id === game.tournament_id),
        targetScore: game.eternumQuest ? (await fetchQuestTarget(game.tokenId)) : null,
      })))

      setSelectedGame()
      setGames(games ?? [])
      setLoading(false)
    }

    fetchGames()
  }, [address, active])

  const handleResumeGame = () => {
    gameContext.actions.loadGameDetails(selectedGame)
    close(false)
  }

  const renderTimeRemaining = (timestamp) => {
    const hours = Math.max(0, Math.floor((timestamp - Date.now()) / (1000 * 60 * 60)));
    const minutes = Math.max(0, Math.floor(((timestamp - Date.now()) % (1000 * 60 * 60)) / (1000 * 60)));

    return (
      <>
        {hours > 0 && (
          <>
            <Typography color='primary' sx={{ fontSize: '13px' }}>
              {hours}
            </Typography>
            <Typography color='primary' sx={{ fontSize: '13px', ml: '2px' }}>
              h
            </Typography>
          </>
        )}
        <Typography color='primary' sx={{ fontSize: '13px', ml: hours > 0 ? '4px' : '0px' }}>
          {minutes}
        </Typography>
        <Typography color='primary' sx={{ fontSize: '13px', ml: '2px' }}>
          m
        </Typography>
      </>
    );
  };

  function renderGame(game) {
    return <Box sx={[styles.gameContainer, { opacity: selectedGame?.id === game.id ? 1 : 0.8 }]}
      border={selectedGame?.id === game.id ? '1px solid #f59100' : '1px solid rgba(255, 255, 255, 0.3)'}
      onClick={() => setSelectedGame(game)}
    >

      <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
        <img alt='' src={logo} height='42' />

        <Box sx={{ display: 'flex', flexDirection: 'column' }}>
          <Typography color='primary' textTransform={'uppercase'} fontSize={'12px'} >
            {game.playerName} - #{game.id}
          </Typography>

          {game.xp ? <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Box display={'flex'}>
              <Typography sx={{ fontSize: '13px' }}>
                {game.health}
              </Typography>

              <FavoriteIcon htmlColor="red" sx={{ fontSize: '18px' }} />
            </Box>

            <Typography color='primary' sx={{ fontSize: '13px' }}>
              {game.xp} XP
            </Typography>
          </Box>
            : <Typography sx={{ fontSize: '13px' }}>
              New
            </Typography>
          }

          <Typography color='secondary' sx={{ fontSize: '13px' }}>
            {hexToAscii(game.settingsMetadata?.name || '')}
          </Typography>
        </Box>
      </Box>

      <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end' }}>
        {active && game.available_at !== 0 && <Box sx={{ display: 'flex', alignItems: 'center', gap: 3 }}>
          {game.available_at < Date.now() ? <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <AccessTimeIcon color='primary' sx={{ fontSize: '16px', mr: '3px' }} />
            {renderTimeRemaining(game.expires_at)}
          </Box> : <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <WatchIcon color='primary' sx={{ fontSize: '16px', mr: '3px' }} />
            {renderTimeRemaining(game.available_at)}
          </Box>}
        </Box>}

        {game.tournament_id ? <Typography sx={{ color: '#f59100', textAlign: 'right' }}>
          {game.tournament?.name}
        </Typography>
          : game.eternumQuest ? <Typography sx={{ color: '#f59100', textAlign: 'right' }}>
            S1 Quest
          </Typography> :
            <Typography sx={{ color: '#fff', opacity: 0.8 }}>
              Free
            </Typography>
        }

        {game.targetScore && <Typography color='#f59100' sx={{ fontSize: '12px' }}>
          {game.targetScore} XP
        </Typography>}
      </Box>
    </Box >
  }

  return (
    <Dialog
      open={open}
      onClose={() => close(false)}
      maxWidth={'lg'}
      PaperProps={{
        sx: { background: 'rgba(0, 0, 0, 1)', border: '1px solid #FFE97F', maxWidth: '98vw' }
      }}
    >
      <Box sx={styles.dialogContainer}>

        <motion.div variants={fadeVariant} exit='exit' animate='enter'>
          <Box sx={styles.container}>

            <Typography color='primary' variant='h3' textAlign={'center'}>
              Game Tokens
            </Typography>

            <Box sx={styles.gamesContainer}>
              <Box sx={{ display: 'flex', width: '100%', alignItems: 'center', justifyContent: 'space-between', mb: 0.5 }}>
                <Box sx={{ display: 'flex', gap: 1 }}>
                  <Button variant='outlined' size='small' color={active ? 'primary' : 'secondary'} onClick={() => showActive(true)}>
                    Active
                  </Button>

                  <Button variant='outlined' size='small' color={!active ? 'primary' : 'secondary'} onClick={() => showActive(false)}>
                    Dead
                  </Button>
                </Box>


              </Box>

              {loading && <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '340px' }}>
                <CircularProgress />
              </Box>}

              {!loading && <Scrollbars style={{ width: '100%', height: '340px' }}>
                {React.Children.toArray(
                  games.filter(game => game.active === active).map(game => renderGame(game))
                )}
              </Scrollbars>}
            </Box>

            <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center' }}>
              <Button color='secondary' variant='outlined' size='large' onClick={() => openGameSettings(true)}
                disabled={!selectedGame}
              >
                View Settings
              </Button>

              <Button variant='outlined' size='large' sx={{ width: '140px' }}
                disabled={!selectedGame || !selectedGame.active || selectedGame.available_at > Date.now()}
                onClick={() => handleResumeGame()}
              >
                Start Game
              </Button>
            </Box>

          </Box>
        </motion.div>

      </Box>

      {gameSettings && <GameSettings settingsId={selectedGame?.settingsId} view={true} close={() => openGameSettings(false)} />}
    </Dialog>
  )
}

export default GameTokens

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
  gameContainer: {
    width: '100%',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderRadius: '2px',
    py: '6px',
    pr: 1,
    gap: 1,
    cursor: 'pointer',
    boxSizing: 'border-box',
    mb: 1
  },
  gamesContainer: {
    width: '370px',
    maxWidth: '100%',
    minHeight: '200px',
    display: 'flex',
    flexDirection: 'column',
    gap: 1,
    mt: 1
  },
}
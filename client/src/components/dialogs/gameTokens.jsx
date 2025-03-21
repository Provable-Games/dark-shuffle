import AccessTimeIcon from '@mui/icons-material/AccessTime';
import FavoriteIcon from '@mui/icons-material/Favorite';
import WatchIcon from '@mui/icons-material/Watch';
import { Box, Button, CircularProgress, Dialog, Typography } from '@mui/material';
import { motion } from "framer-motion";
import React, { useEffect, useState } from 'react';
import Scrollbars from 'react-custom-scrollbars';
import { getGameTokens, populateGameTokens } from '../../api/indexer';
import logo from '../../assets/images/logo.svg';
import { useTournament } from '../../contexts/tournamentContext';
import { fadeVariant } from "../../helpers/variants";

function GameTokens(props) {
  const { tournaments } = useTournament()
  const { open, close, address, resumeGame, startGame } = props

  const [games, setGames] = useState([])
  const [selectedGame, setSelectedGame] = useState()

  const [active, showActive] = useState(true)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function fetchGames() {
      setLoading(true)

      const gameTokens = await getGameTokens(address)
      let games = await populateGameTokens(gameTokens.map(game => game.tokenId))

      games = games.map(game => ({
        ...game,
        tournament: tournaments.find(tournament => tournament.id === game.tournament_id)
      }))

      setSelectedGame()
      setGames(games ?? [])
      setLoading(false)
    }

    fetchGames()
  }, [address, active])

  const handleResumeGame = () => {
    if (selectedGame.xp) {
      resumeGame(selectedGame)
    } else {
      startGame(selectedGame)
    }

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
          <Typography color='primary' textTransform={'uppercase'} fontSize={'12px'}>
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

        {game.tournament_id ? <Typography sx={{ color: '#f59100' }}>
          {game.tournament?.name}
        </Typography> : <Typography sx={{ color: '#fff', opacity: 0.8 }}>
          Free
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
        sx: { background: 'rgba(0, 0, 0, 1)', border: '1px solid #FFE97F' }
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
              <Button variant='outlined' size='large'
                disabled={!selectedGame || !selectedGame.active || selectedGame.available_at > Date.now()}
                onClick={() => handleResumeGame()}
              >
                Start Game
              </Button>
            </Box>

          </Box>
        </motion.div>

      </Box>
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
    width: '360px',
    maxWidth: '100%',
    minHeight: '200px',
    display: 'flex',
    flexDirection: 'column',
    gap: 1,
    mt: 1
  },
}
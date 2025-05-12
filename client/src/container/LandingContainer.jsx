import { LoadingButton } from '@mui/lab'
import { Box, Button, Typography } from '@mui/material'
import { useAccount } from '@starknet-react/core'
import React, { useContext, useState } from 'react'
import { BrowserView, MobileView } from 'react-device-detect'
import logo from '../assets/images/logo.svg'
import GameSettingsList from '../components/dialogs/gameSettingsList'
import GameTokens from '../components/dialogs/gameTokens'
import Leaderboard from '../components/landing/leaderboard'
import Monsters from '../components/landing/monsters'
import { GameContext } from '../contexts/gameContext'
import { useTournament } from '../contexts/tournamentContext'
import { _styles } from '../helpers/styles'
import { useParams } from 'react-router-dom'
import GameSettings from '../components/dialogs/gameSettings'
import GGQuest from '../components/dialogs/ggQuest'

function LandingContainer() {
  const tournamentProvider = useTournament()

  const { showSettingsId } = useParams()
  const { address } = useAccount()

  const gameState = useContext(GameContext)
  const [gamesDialog, openGamesDialog] = useState(false)
  const [gameSettingsList, openGameSettingsList] = useState(false)
  const [gameSettings, openGameSettings] = useState(Boolean(showSettingsId))

  return (
    <>
      <MobileView>
        <Box sx={styles.mobileContainer}>
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <Typography variant='h2' color='primary' fontSize={'30px'}>
              Dark Shu
            </Typography>

            <Box mb={'-19px'} ml={'-8px'} mr={'-7px'}>
              <img alt='' src={logo} height='42' />
            </Box>

            <Typography variant='h2' color='primary' fontSize={'30px'}>
              le
            </Typography>
          </Box>

          <Box sx={[styles.kpi, { width: '100%', height: '90px', mt: 1 }]}>
            <Typography>
              Game Cost
            </Typography>
            <Typography variant='h5' color='primary'>
              Free
            </Typography>
          </Box>

          <Box sx={[styles.kpi, { width: '100%', height: '90px', mb: 1 }]}>
            <Typography>
              Active Tournaments
            </Typography>
            <Typography variant='h5' color='primary'>
              {tournamentProvider.tournaments.length}
            </Typography>
          </Box>

          <Typography variant='h3' textAlign={'center'}>
            Call to Arms
          </Typography>

          <LoadingButton variant='outlined' loading={gameState.getState.startStatus} onClick={() => openGameSettingsList(true)} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
            Play Game
          </LoadingButton>

          <Button disabled={!address} variant='outlined' onClick={() => openGamesDialog(true)} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
            My Games
          </Button>

          <Button color='warning' variant='outlined' onClick={() => window.open("https://budokan.gg/", "_blank")} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
            Tournaments
          </Button>

          <Box width={'100%'} sx={_styles.customBox} mt={1}>

            <Leaderboard />

          </Box>
        </Box>
      </MobileView>

      <BrowserView>
        <Box sx={styles.browserContainer}>

          <Box width={'100%'} display={'flex'} alignItems={'flex-start'} justifyContent={'space-between'} gap={2}>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, pl: 2 }}>
              <Box sx={{ display: 'flex', alignItems: 'center' }}>
                <Typography variant='h2' color='primary' fontSize={'30px'}>
                  Dark Shu
                </Typography>

                <Box mb={'-19px'} ml={'-8px'} mr={'-7px'}>
                  <img alt='' src={logo} height='42' />
                </Box>

                <Typography variant='h2' color='primary' fontSize={'30px'}>
                  le
                </Typography>
              </Box>

              <Typography variant='h6'>
                A Provable Roguelike Deck-building Game on Starknet, powered by $LORDS.
              </Typography>
            </Box>

            <Box display='flex' gap={2}>
              <Box sx={[styles.kpi]}>
                <Typography>
                  Game Cost
                </Typography>
                <Typography variant='h5' color='primary'>
                  Free
                </Typography>
              </Box>

              <Box sx={[styles.kpi]}>
                <Typography>
                  Active Tournaments
                </Typography>
                <Typography variant='h5' color='primary'>
                  {tournamentProvider.tournaments.length}
                </Typography>
              </Box>
            </Box>
          </Box>

          <Monsters />

          <Box sx={[_styles.customBox, _styles.linearBg, { display: 'flex', justifyContent: 'space-between', p: 2 }]} width={'100%'}>

            <Box sx={{ maxWidth: '800px' }}>
              <Box sx={{ display: 'flex', alignItems: 'baseline', gap: 3 }}>
                <Typography variant='h3'>
                  Call to Arms
                </Typography>
              </Box>

              <ul style={{ paddingLeft: '16px', color: '#FFE97F' }}>
                <li>
                  <Typography mt={3} style={{ fontSize: '15px' }} color={'primary'}>
                    Draft 20 powerful cards to kickstart your journey, shaping your strategy from the very beginning.
                  </Typography>
                </li>

                <li>
                  <Typography mt={2} style={{ fontSize: '15px' }} color={'primary'}>
                    Explore randomly generated maps filled with branching paths and unpredictable challenges.
                  </Typography>
                </li>

                <li>
                  <Typography mt={2} style={{ fontSize: '15px' }} color={'primary'}>
                    Engage in strategic card-based battles against fierce beasts.
                  </Typography>
                </li>

                <li>
                  <Typography mt={2} style={{ fontSize: '15px' }} color={'primary'}>
                    Climb the leaderboard to earn rewards and prove your mastery.
                  </Typography>
                </li>
              </ul>

              <Box mt={4} display={'flex'} alignItems={'center'} gap={1.5}>
                <LoadingButton variant='outlined' loading={gameState.getState.startStatus}
                  onClick={() => openGameSettingsList(true)} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
                  Play Game
                </LoadingButton>

                <Button disabled={!address} variant='outlined' onClick={() => openGamesDialog(true)} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
                  My Games
                </Button>

                <Button color='warning' variant='outlined' onClick={() => window.open("https://budokan.gg/", "_blank")} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
                  Tournaments
                </Button>
              </Box>
            </Box>

            <Box width={'500px'} sx={_styles.customBox}>

              <Leaderboard />

            </Box>

          </Box>

        </Box >
      </BrowserView>

      {gamesDialog && <GameTokens open={gamesDialog} close={openGamesDialog} address={address} />}
      {gameSettingsList && <GameSettingsList open={gameSettingsList} close={openGameSettingsList} />}
      {gameSettings && <GameSettings settingsId={showSettingsId} view={true} close={() => openGameSettings(false)} />}

      <GGQuest open={gameState.getState.GG_questMode} />
    </>
  )
}

export default LandingContainer

const styles = {
  mobileContainer: {
    width: '100%',
    maxWidth: '600px',
    margin: 'auto',
    display: 'flex',
    flexDirection: 'column',
    boxSizing: 'border-box',
    gap: 2,
    p: 2
  },
  browserContainer: {
    width: '100%',
    height: 'calc(100% - 55px)',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    boxSizing: 'border-box',
    gap: 3.5,
    p: 4,
    px: 2,
    pt: 2
  },
  startContainer: {
    maxWidth: 'calc(100% - 500px)',
    width: '800px',
    display: 'flex',
    flexDirection: 'column',
    gap: 2
  },
  seasonContainer: {
    width: '500px',
    display: 'flex',
    flexDirection: 'column',
    gap: 2
  },
  kpi: {
    width: '220px',
    height: '90px',
    background: 'linear-gradient(to right, rgba(0, 0, 0, 0.7), rgba(0, 0, 0, 0.5))',
    boxSizing: 'border-box',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'space-evenly',
    p: 2
  }
}
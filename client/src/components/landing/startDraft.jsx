import CloseIcon from '@mui/icons-material/Close'
import { LoadingButton, Skeleton } from '@mui/lab'
import { Box, Button, IconButton, Typography } from '@mui/material'
import { useAccount, useConnect } from '@starknet-react/core'
import { useSnackbar } from 'notistack'
import React, { useContext, useEffect, useState } from 'react'
import { BrowserView, MobileView } from 'react-device-detect'
import { useParams } from 'react-router-dom'
import { getActiveGame, getGameEffects, getMap, getSettings, getTokenMetadata } from '../../api/indexer'
import logo from '../../assets/images/logo.svg'
import { BattleContext } from '../../contexts/battleContext'
import { DojoContext } from '../../contexts/dojoContext'
import { DraftContext } from '../../contexts/draftContext'
import { GAME_STATES, GameContext } from '../../contexts/gameContext'
import { useReplay } from '../../contexts/replayContext'
import { useTournament } from '../../contexts/tournamentContext'
import { generateMapNodes } from '../../helpers/map'
import { _styles } from '../../helpers/styles'
import { formatTimeUntil } from '../../helpers/utilities'
import GameTokens from '../dialogs/gameTokens'
import LoadingReplayDialog from '../dialogs/loadingReplay'
import ReconnectDialog from '../dialogs/reconnecting'
import StartGameDialog from '../dialogs/startGame'
import Leaderboard from './leaderboard'
import Monsters from './monsters'

function StartDraft() {
  const tournamentProvider = useTournament()
  const { season } = tournamentProvider

  const replay = useReplay()
  const { gameId } = useParams()
  const { account, address } = useAccount()
  const { connect, connectors } = useConnect();
  const { enqueueSnackbar, closeSnackbar } = useSnackbar()

  const dojo = useContext(DojoContext)
  const gameState = useContext(GameContext)
  const battle = useContext(BattleContext)
  const draft = useContext(DraftContext)

  let cartridgeConnector = connectors.find(conn => conn.id === "controller")

  const [startingSeasonGame, setStartingSeasonGame] = useState(false)
  const [gamesDialog, openGamesDialog] = useState(false)
  const [reconnecting, setReconnecting] = useState(false)
  const [previousGame, setPreviousGame] = useState()

  useEffect(() => {
    async function loadGame() {
      if (!account) {
        connect({ connector: cartridgeConnector })
        return
      }

      if (gameId) {
        let game = await getTokenMetadata(gameId)
        if (game.active) {
          loadGameSettings(game)
        } else {
          startMintedGame(game)
        }
      }
    }

    if (gameId) {
      loadGame()
    }
  }, [gameId, account])

  const stopReconnecting = () => {
    setReconnecting(false)
    setPreviousGame()
  }

  const startSeasonGame = async () => {
    if (dojo.balances.lords < season.entryFee) {
      enqueueSnackbar('You do not have enough $LORDS to enter the season', { variant: 'warning' })
      return
    }

    setStartingSeasonGame(true)
    gameState.setStartStatus('Minting Game Token')

    let tokenData = await tournamentProvider.actions.enterTournament(season.tournamentId)

    if (!tokenData) {
      setStartingSeasonGame(false)
      gameState.setStartStatus()
      return
    }

    startMintedGame(tokenData)
  }

  const startFreeGame = async () => {
    setStartingSeasonGame(false)
    gameState.setStartStatus('Minting Game Token')

    let tokenData = await gameState.actions.mintFreeGame()
    startMintedGame(tokenData)
  }

  const startMintedGame = async (tokenData) => {
    await draft.actions.prepareStartingGame(tokenData)

    enqueueSnackbar('Share Your Game!', {
      variant: 'info',
      anchorOrigin: { vertical: 'bottom', horizontal: 'right' },
      autoHideDuration: 15000,
      hideIconVariant: true,
      action: snackbarId => (
        <>
          <Button variant='outlined' size='small' sx={{ width: '90px', mr: 1 }}
            component='a' href={'https://x.com/intent/tweet?text=' + `I'm about to face the beasts of Dark Shuffle — come watch me play and see how far I can go! darkshuffle.io/watch/${tokenData?.tokenId} 🕷️⚔️ @provablegames @darkshuffle_gg`}
            target='_blank'>
            Tweet
          </Button>

          <IconButton size='small' onClick={() => {
            closeSnackbar(snackbarId)
          }}>
            <CloseIcon color='secondary' fontSize='small' />
          </IconButton>
        </>
      )
    })
  }

  const loadGameSettings = async (game) => {
    setReconnecting(true)
    setPreviousGame(game)
    gameState.utils.initializeGameSettings(game.settingsId)
  }

  const loadActiveGame = async () => {
    try {
      let data = await getActiveGame(previousGame.id)
      data.state = GAME_STATES[data.state]

      let settings = await getSettings(previousGame.settingsId)

      gameState.setGameSettings(settings)

      await draft.actions.fetchDraft(data.game_id)

      if (data.state !== 'Draft') {
        let map = await getMap(data.game_id, data.map_level)

        if (map) {
          let computedMap = generateMapNodes(map.level, map.seed)

          gameState.setMap(computedMap.map(node => {
            return {
              ...node,
              active: node.parents.includes(data.last_node_id) || (node.nodeId === 1 && data.map_depth === 1),
              status: node.nodeId === data.last_node_id ? 1 : 0
            }
          }))
        }

        if (data.state === 'Battle') {
          await battle.utils.fetchBattleState(data.monsters_slain + 1, data.game_id)
        }

        const effects = await getGameEffects(data.game_id)
        if (effects) {
          gameState.setGameEffects({
            firstAttack: effects.first_attack,
            firstHealth: effects.first_health,
            allAttack: effects.all_attack,
            hunterAttack: effects.hunter_attack,
            hunterHealth: effects.hunter_health,
            magicalAttack: effects.magical_attack,
            magicalHealth: effects.magical_health,
            bruteAttack: effects.brute_attack,
            bruteHealth: effects.brute_health,
            heroDmgReduction: effects.hero_dmg_reduction,
            heroCardHeal: effects.hero_card_heal,
            cardDraw: effects.card_draw,
            playCreatureHeal: effects.play_creature_heal,
            startBonusEnergy: effects.start_bonus_energy
          })
        }
      }

      gameState.setGame({
        gameId: data.game_id,
        state: data.state,

        playerName: previousGame.playerName,

        heroHealth: data.hero_health,
        heroXp: data.hero_xp,
        monstersSlain: data.monsters_slain,

        mapLevel: data.map_level,
        mapDepth: data.map_depth,
        lastNodeId: data.last_node_id,

        replay: Boolean(replay.spectatingGame?.id)
      })

      stopReconnecting()
    } catch (ex) {
      console.log(ex)
      stopReconnecting()
      enqueueSnackbar('Failed To Reconnect', { variant: 'warning' })
    }
  }

  let currentTime = Date.now() / 1000

  useEffect(() => {
    if (replay.spectatingGame) {
      loadActiveGame(replay.spectatingGame)
    }
  }, [replay.spectatingGame])

  useEffect(() => {
    if (previousGame && gameState.getState.gameSettings?.starting_health && gameState.getState.gameCards?.length > 0) {
      loadActiveGame()
    }
  }, [previousGame, gameState.getState.gameSettings, gameState.getState.gameCards])

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
            <Typography variant='h6'>
              Season Pool
            </Typography>
            <Typography variant='h5' color='primary'>
              {Math.floor(season.rewardPool / 1e18 * 1)} $LORDS
            </Typography>
            <Typography variant='h6' color='#f59100'>
              +300 $CASH
            </Typography>
          </Box>

          <Box sx={[styles.kpi, { width: '100%', height: '90px', mb: 1 }]}>
            <Typography>
              {season.end > currentTime ? `Round 1 ${season.start > currentTime ? 'begins in' : 'ends in'}` : 'Round 1'}
            </Typography>
            <Typography variant='h5' color='primary'>
              {season.start > currentTime ? `${formatTimeUntil(season.start)}` : (season.end > currentTime ? `${formatTimeUntil(season.end)}` : 'Finished')}
            </Typography>
          </Box>

          <Typography variant='h3' textAlign={'center'}>
            TEST TOURNEY
          </Typography>

          <Typography variant='h6' color='#f59100' textAlign={'center'}>
            Enter tournament on <a href="https://budokan.gg/tournament/1" target='_blank' className='underline' style={{ color: '#f59100' }}>Budokan</a>
          </Typography>

          {/* <LoadingButton variant='outlined'
            loading={gameState.getState.startStatus || !season.entryFee}
            onClick={() => startSeasonGame()}
            sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}
            disabled={season.start < currentTime}
          >
            Play Season
          </LoadingButton> */}

          <Button disabled={!address} variant='outlined' onClick={() => openGamesDialog(true)} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
            My Games
          </Button>

          <LoadingButton color='secondary' variant='outlined' loading={gameState.getState.startStatus} onClick={() => startFreeGame()} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
            Play Demo
          </LoadingButton>

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
                  {season.end > currentTime ? `Round 1 ${season.start > currentTime ? 'begins in' : 'ends in'}` : 'Round 1'}
                </Typography>
                {season.start ? <Typography variant='h5' color='primary'>
                  {season.start > currentTime ? `${formatTimeUntil(season.start)}` : (season.end > currentTime ? `${formatTimeUntil(season.end)}` : 'Finished')}
                </Typography> : <Skeleton variant='text' width={'80%'} height={32} />}
              </Box>

              <Box sx={styles.kpi}>
                <Typography>
                  Tournament Entry
                </Typography>
                {season.entryFee ? <Typography variant={'h5'} color='primary'>
                  {season.start > currentTime ? `${Math.floor(season.entryFee / 1e18)} $LORDS` : 'Closed'}
                </Typography> : <Skeleton variant='text' width={'80%'} height={32} />}
              </Box>

              <Box sx={[styles.kpi, { position: 'relative' }]}>
                <Box display={'flex'} justifyContent={'space-between'}>
                  <Typography>
                    Prize Pool
                  </Typography>
                </Box>
                {season.rewardPool !== undefined ? <Typography variant={'h5'} color='primary'>
                  {Math.floor(season.rewardPool / 1e18 * 1)} $LORDS
                </Typography> : <Skeleton variant='text' width={'80%'} height={32} />}
                {/* <Typography color='#f59100' sx={{ position: 'absolute', bottom: 2, left: '16px' }}>
                  +300 $CASH
                </Typography> */}
              </Box>
            </Box>
          </Box>

          <Monsters />

          <Box sx={[_styles.customBox, _styles.linearBg, { display: 'flex', justifyContent: 'space-between', p: 2 }]} width={'100%'}>

            <Box sx={{ maxWidth: '800px' }}>
              <Box sx={{ display: 'flex', alignItems: 'baseline', gap: 3 }}>
                <Typography variant='h3'>
                  TEST TOURNEY
                </Typography>

                <Typography variant='h6' color='#f59100'>
                  Enter tournament on <a href="https://budokan.gg/tournament/1" target='_blank' className='underline' style={{ color: '#f59100' }}>Budokan</a>
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

              <Box mt={4} display={'flex'} alignItems={'center'} gap={2}>
                {/* <LoadingButton variant='outlined'
                  loading={gameState.getState.startStatus || !season.entryFee}
                  onClick={() => startSeasonGame()}
                  sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}
                  disabled={season.start < currentTime}
                >
                  Play Season
                </LoadingButton> */}

                <Button disabled={!address} variant='outlined' onClick={() => openGamesDialog(true)} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
                  My Games
                </Button>

                <LoadingButton color='secondary' variant='outlined' loading={gameState.getState.startStatus} disabled={!address}
                  onClick={() => startFreeGame()} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
                  Play Demo
                </LoadingButton>
              </Box>
            </Box>

            <Box width={'500px'} sx={_styles.customBox}>

              <Leaderboard />

            </Box>

          </Box>

        </Box >
      </BrowserView>

      {gameState.getState.startStatus && <StartGameDialog status={gameState.getState.startStatus} isSeason={startingSeasonGame} />}
      {gamesDialog && <GameTokens open={gamesDialog} close={openGamesDialog} address={address} resumeGame={loadGameSettings} startGame={startMintedGame} />}
      {reconnecting && <ReconnectDialog close={stopReconnecting} />}
      {(replay.loadingReplay && !replay.translatedEvents[0]) && <LoadingReplayDialog close={() => replay.endReplay()} />}
    </>
  )
}

export default StartDraft

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
import { LoadingButton, Skeleton } from '@mui/lab'
import { Box, Button, Typography } from '@mui/material'
import { useAccount, useConnect } from '@starknet-react/core'
import { useSnackbar } from 'notistack'
import React, { useContext, useEffect, useState } from 'react'
import { BrowserView, MobileView } from 'react-device-detect'
import { useParams } from 'react-router-dom'
import { getActiveGame, getGameEffects, getMap, getTokenMetadata } from '../../api/indexer'
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
  const { connect, connectors, isPending } = useConnect();
  const { enqueueSnackbar } = useSnackbar()

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
      if (!Boolean(account)) {
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

    if (gameId && !isPending) {
      loadGame()
    }
  }, [gameId, address, isPending])

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
    if (!Boolean(account)) {
      connect({ connector: cartridgeConnector })
      return
    }

    setStartingSeasonGame(false)
    gameState.setStartStatus('Minting Game Token')

    let tokenData = await gameState.actions.mintFreeGame()
    startMintedGame(tokenData)
  }

  const startMintedGame = async (tokenData) => {
    gameState.setStartStatus('Loading Game Settings')
    await draft.actions.prepareStartingGame(tokenData)
  }

  const loadGameSettings = async (game) => {
    setReconnecting(true)
    setPreviousGame(game)
    gameState.utils.initializeGameSettings(game.settingsId)
  }

  const loadActiveGame = async (game) => {
    let settings = gameState.getState.gameSettings

    try {
      let data = await getActiveGame(game.id)
      data.state = GAME_STATES[data.state]

      await draft.actions.fetchDraft(data.game_id)

      if (data.state !== 'Draft') {
        let map = await getMap(data.game_id, data.map_level)

        if (map) {
          let computedMap = generateMapNodes(map.level, map.seed, settings)

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

        playerName: game.playerName,

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

    gameState.setStartStatus()
  }

  let currentTime = Date.now() / 1000

  useEffect(() => {
    if ((previousGame || replay.spectatingGame) && gameState.getState.gameSettings?.starting_health && gameState.getState.gameCards?.length > 0) {
      loadActiveGame(previousGame || replay.spectatingGame)
    }
  }, [previousGame, replay.spectatingGame, gameState.getState.gameSettings, gameState.getState.gameCards])

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

          {/* <Box sx={[styles.kpi, { width: '100%', height: '90px', mt: 1 }]}>
            <Typography variant='h6'>
              Prize Pool
            </Typography>
            <Typography variant='h5' color='primary'>
              {Math.floor(season.rewardPool / 1e18 * 1)} $LORDS
            </Typography>
            <Typography variant='h6' color='#f59100'>
              +300 $CASH
            </Typography>
          </Box> */}

          <Box sx={[styles.kpi, { width: '100%', height: '90px', mt: 1 }]}>
            <Typography>
              {season.end > currentTime ? `Season ${season.start > currentTime ? 'begins in' : 'ends in'}` : 'Season'}
            </Typography>
            <Typography variant='h5' color='primary'>
              {season.start > currentTime ? `${formatTimeUntil(season.start)}` : (season.end > currentTime ? `${formatTimeUntil(season.end)}` : (season.end + season.submissionPeriod > currentTime ? `validating scores` : 'Finished'))}
            </Typography>
          </Box>

          <Box sx={[styles.kpi, { width: '100%', height: '90px', mb: 1 }]}>
            <Typography color='primary' textAlign={'center'}>
              Sepolia
            </Typography>
          </Box>

          <Typography variant='h3' textAlign={'center'}>
            Test Version 1.2
          </Typography>

          {/* <LoadingButton variant='outlined'
            loading={gameState.getState.startStatus || !season.entryFee}
            onClick={() => startSeasonGame()}
            sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}
            disabled={season.start < currentTime}
          >
            Play Season
          </LoadingButton> */}
          <LoadingButton variant='outlined' loading={gameState.getState.startStatus} onClick={() => startFreeGame()} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
            Play Game
          </LoadingButton>

          <Button disabled={!address} variant='outlined' onClick={() => openGamesDialog(true)} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
            My Games
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
                  {season.end > currentTime ? `Season ${season.start > currentTime ? 'begins in' : 'ends in'}` : 'Season'}
                </Typography>
                {season.start ? <Typography variant='h5' color='primary'>
                  {season.start > currentTime ? `${formatTimeUntil(season.start)}` : (season.end > currentTime ? `${formatTimeUntil(season.end)}` : (season.end + season.submissionPeriod > currentTime ? `validating scores` : 'Finished'))}
                </Typography> : <Skeleton variant='text' width={'80%'} height={32} />}
              </Box>

              {/* <Box sx={styles.kpi}>
                <Typography>
                  Tournament Entry
                </Typography>
                {season.entryFee ? <Typography variant={'h5'} color='primary'>
                  {season.start > currentTime ? `${Math.floor(season.entryFee / 1e18)} $LORDS` : 'Closed'}
                </Typography> : <Skeleton variant='text' width={'80%'} height={32} />}
              </Box> */}

              <Box sx={[styles.kpi, { position: 'relative' }]}>
                <Typography color='primary' textAlign={'center'}>
                  Sepolia
                </Typography>
              </Box>
            </Box>
          </Box>

          <Monsters />

          <Box sx={[_styles.customBox, _styles.linearBg, { display: 'flex', justifyContent: 'space-between', p: 2 }]} width={'100%'}>

            <Box sx={{ maxWidth: '800px' }}>
              <Box sx={{ display: 'flex', alignItems: 'baseline', gap: 3 }}>
                <Typography variant='h3'>
                  Test Version 1.2
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
                <LoadingButton variant='outlined' loading={gameState.getState.startStatus}
                  onClick={() => startFreeGame()} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
                  Play Game
                </LoadingButton>

                <Button disabled={!address} variant='outlined' onClick={() => openGamesDialog(true)} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
                  My Games
                </Button>
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
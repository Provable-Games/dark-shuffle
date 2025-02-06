import { hexToAscii } from '@dojoengine/utils'
import { LoadingButton, Skeleton } from '@mui/lab'
import { Box, Button, Typography } from '@mui/material'
import { useAccount } from '@starknet-react/core'
import { useSnackbar } from 'notistack'
import React, { useContext, useState } from 'react'
import { BrowserView, MobileView } from 'react-device-detect'
import { getActiveGame, getGameEffects, getMap } from '../../api/indexer'
import logo from '../../assets/images/logo.svg'
import { BattleContext } from '../../contexts/battleContext'
import { DraftContext } from '../../contexts/draftContext'
import { GameContext } from '../../contexts/gameContext'
import { useSeason } from '../../contexts/seasonContext'
import { generateMapNodes } from '../../helpers/map'
import { _styles } from '../../helpers/styles'
import { formatTimeUntil } from '../../helpers/utilities'
import GameTokens from '../dialogs/gameTokens'
import ReconnectDialog from '../dialogs/reconnecting'
import StartGameDialog from '../dialogs/startGame'
import Leaderboard from './leaderboard'
import Monsters from './monsters'
import { DojoContext } from '../../contexts/dojoContext'
import StartSeason from '../dialogs/startSeason'
import { useReplay } from '../../contexts/replayContext'
import { useEffect } from 'react'
import LoadingReplayDialog from '../dialogs/loadingReplay'
import { fetchGameSettings } from '../../api/starknet'

function StartDraft() {
  const season = useSeason()
  const replay = useReplay()

  const { address } = useAccount()
  const { enqueueSnackbar } = useSnackbar()

  const dojo = useContext(DojoContext)
  const gameState = useContext(GameContext)
  const battle = useContext(BattleContext)
  const draft = useContext(DraftContext)
  const { status } = draft.getState

  const [showWarnings, setShowWarnings] = useState(false)
  const [gamesDialog, openGamesDialog] = useState(false)
  const [reconnecting, setReconnecting] = useState(false)

  const [startSeasonDialog, openStartSeasonDialog] = useState(false)

  async function beginDraft(isSeason) {
    if (isSeason) {
      if (dojo.balances.lords < season.values.entryFee) {
        enqueueSnackbar('You do not have enough $LORDS to enter the season', { variant: 'warning' })
        return
      }

      setShowWarnings(true)
    }

    await draft.actions.startDraft(isSeason)
  }

  const startGame = async (isSeason, gameId) => {
    await draft.actions.startDraft(isSeason, gameId)
  }

  const resumeGame = async (game_id) => {
    setReconnecting(true)

    try {
      let data = await getActiveGame(game_id)
      let settings = await fetchGameSettings(game_id)

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
            firstCreatureCost: effects.first_creature_cost,
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
        seasonId: data.season_id,
        player_name: hexToAscii(data.player_name),
        state: data.state,

        heroHealth: data.hero_health,
        heroXp: data.hero_xp,
        monstersSlain: data.monsters_slain,

        mapLevel: data.map_level,
        mapDepth: data.map_depth,
        lastNodeId: data.last_node_id,

        replay: Boolean(replay.spectatingGameId)
      })

      setReconnecting(false)
    } catch (ex) {
      console.log(ex)
      setReconnecting(false)
      enqueueSnackbar('Failed To Reconnect', { variant: 'warning' })
    }
  }

  let currentTime = Date.now() / 1000

  useEffect(() => {
    if (replay.spectatingGameId) {
      resumeGame(replay.spectatingGameId)
    }
  }, [replay.spectatingGameId])

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
              {Math.floor(season.values.rewardPool / 1e18)} $LORDS
            </Typography>

          </Box>

          <Box sx={[styles.kpi, { width: '100%', height: '90px', mb: 1 }]}>
            <Typography>
              {season.values.end > currentTime ? `Season 1 ${season.values.start > currentTime ? 'begins in' : 'ends in'}` : 'Season 1'}
            </Typography>
            <Typography variant='h5' color='primary'>
              {season.values.start > currentTime ? `${formatTimeUntil(season.values.start)}` : (season.values.end > currentTime ? `${formatTimeUntil(season.values.end)}` : 'Finished')}
            </Typography>
          </Box>

          <Typography variant='h3' textAlign={'center'}>
            Season 1: New beginnings
          </Typography>

          <LoadingButton variant='outlined'
            loading={status || !season.values.entryFee}
            onClick={() => openStartSeasonDialog(true)}
            sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}
            disabled={season.values.start > currentTime || season.values.end < currentTime}
          >
            Play Season
          </LoadingButton>

          <Button disabled={!address} variant='outlined' onClick={() => openGamesDialog(true)} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
            My Games
          </Button>

          <LoadingButton color='secondary' variant='outlined' loading={status} onClick={() => beginDraft(false)} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
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
                  {season.values.end > currentTime ? `Season 1 ${season.values.start > currentTime ? 'begins in' : 'ends in'}` : 'Season 1'}
                </Typography>
                {season.values.start ? <Typography variant='h5' color='primary'>
                  {season.values.start > currentTime ? `${formatTimeUntil(season.values.start)}` : (season.values.end > currentTime ? `${formatTimeUntil(season.values.end)}` : 'Finished')}
                </Typography> : <Skeleton variant='text' width={'80%'} height={32} />}
              </Box>

              <Box sx={styles.kpi}>
                <Typography>
                  Season Entry
                </Typography>
                {season.values.entryFee ? <Typography variant={'h5'} color='primary'>
                  {Math.floor(season.values.entryFee / 1e18)} $LORDS
                </Typography> : <Skeleton variant='text' width={'80%'} height={32} />}
              </Box>

              <Box sx={styles.kpi}>
                <Box display={'flex'} justifyContent={'space-between'}>
                  <Typography>
                    Season Pool
                  </Typography>
                </Box>
                {season.values.rewardPool !== undefined ? <Typography variant={'h5'} color='primary'>
                  {Math.floor(season.values.rewardPool / 1e18)} $LORDS
                </Typography> : <Skeleton variant='text' width={'80%'} height={32} />}
              </Box>
            </Box>
          </Box>

          <Monsters />

          <Box sx={[_styles.customBox, _styles.linearBg, { display: 'flex', justifyContent: 'space-between', p: 2 }]} width={'100%'}>

            <Box sx={{ maxWidth: '800px' }}>
              <Typography variant='h3'>
                Season 1: Spellbound
              </Typography>

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
                    Climb the leaderboard to earn a share of the season reward pool and prove your mastery.
                  </Typography>
                </li>
              </ul>

              <Box mt={4} display={'flex'} alignItems={'center'} gap={2}>
                <LoadingButton variant='outlined'
                  loading={status || !season.values.entryFee}
                  onClick={() => openStartSeasonDialog(true)}
                  sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}
                  disabled={season.values.start > currentTime || season.values.end < currentTime}
                >
                  Play Season
                </LoadingButton>

                <Button disabled={!address} variant='outlined' onClick={() => openGamesDialog(true)} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
                  My Games
                </Button>

                <LoadingButton color='secondary' variant='outlined' loading={status}
                  onClick={() => beginDraft(false)} sx={{ fontSize: '20px', letterSpacing: '2px', textTransform: 'none' }}>
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

      {startSeasonDialog && <StartSeason open={startSeasonDialog} close={openStartSeasonDialog} start={() => beginDraft(true)} />}
      {status && <StartGameDialog status={status} isSeason={showWarnings} />}
      {gamesDialog && <GameTokens open={gamesDialog} close={openGamesDialog} address={address} resumeGame={resumeGame} startGame={startGame} />}
      {reconnecting && <ReconnectDialog close={() => setReconnecting(false)} />}
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
import { Box, LinearProgress, Typography } from '@mui/material'
import React, { useContext, useEffect, useState } from 'react'
import { getActiveGame, getGameEffects, getMap } from '../api/indexer'
import { BattleContext } from '../contexts/battleContext'
import { DraftContext } from '../contexts/draftContext'
import { GAME_STATES, GameContext } from '../contexts/gameContext'
import { useReplay } from '../contexts/replayContext'
import { generateMapNodes } from '../helpers/map'
import { fetch_card_image } from '../helpers/cards'
import { LazyLoadImage } from 'react-lazy-load-image-component'

const loadingBeasts = ["Warlock", "Anansi", "Manticore", "Phoenix", "Minotaur", "Colossus", "Balrog"]

function LoadingContainer() {
  const replay = useReplay()

  const gameContext = useContext(GameContext)
  const { gameSettings, tokenData, gameCards, loadingProgress } = gameContext.getState;

  const battle = useContext(BattleContext)
  const draft = useContext(DraftContext)

  const [isLoading, setIsLoading] = useState(0)
  const [currentBeastIndex, setCurrentBeastIndex] = useState(Math.floor(Math.random() * loadingBeasts.length))
  const [fadeState, setFadeState] = useState('fade-in')
  const [animatedProgress, setAnimatedProgress] = useState(0)


  useEffect(() => {
    if (!replay.loadingReplay && tokenData.gameStarted && gameSettings?.starting_health && gameCards?.length > 0) {
      loadActiveGame()
    }
  }, [tokenData, gameSettings, gameCards])

  useEffect(() => {
    const beastInterval = setInterval(() => {
      setFadeState('fade-out')

      setTimeout(() => {
        setCurrentBeastIndex((prevIndex) => (prevIndex + 1) % loadingBeasts.length)
        setFadeState('fade-in')
      }, 500)

    }, 4000)

    return () => clearInterval(beastInterval)
  }, [])

  // Animate progress bar
  useEffect(() => {
    // If the target progress is less than current animated progress, just set it directly
    if (loadingProgress < animatedProgress) {
      setAnimatedProgress(loadingProgress);
      return;
    }

    // Determine animation speed based on whether the game has started
    const isGameStarted = tokenData.gameStarted;

    // Calculate how much to increment per step
    const diff = loadingProgress - animatedProgress;
    const step = Math.max(1, Math.ceil(diff / (isGameStarted ? 20 : 40))); // Faster for started games

    // Set up the animation interval
    const interval = setInterval(() => {
      setAnimatedProgress(prev => {
        const newValue = Math.min(prev + step, loadingProgress);
        if (newValue >= loadingProgress) {
          clearInterval(interval);
        }
        return newValue;
      });
    }, isGameStarted ? 50 : 100); // Faster interval for started games

    return () => clearInterval(interval);
  }, [loadingProgress, tokenData.gameStarted]);

  const loadActiveGame = async () => {
    gameContext.setLoadingProgress(99)

    try {
      let data = await getActiveGame(tokenData.id)
      data.state = GAME_STATES[data.state]

      if (data.state === 'None') {
        gameContext.setScore(data.hero_xp)
      }

      await draft.actions.fetchDraft(data.game_id)

      if (data.state !== 'Draft') {
        let map = await getMap(data.game_id, data.map_level)

        if (map) {
          let computedMap = generateMapNodes(map.level, map.seed, gameSettings)

          gameContext.setMap(computedMap.map(node => {
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
          gameContext.setGameEffects({
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

      gameContext.setGame({
        gameId: data.game_id,
        state: data.state,

        playerName: tokenData.playerName,

        heroHealth: data.hero_health,
        heroXp: data.hero_xp,
        monstersSlain: data.monsters_slain,

        mapLevel: data.map_level,
        mapDepth: data.map_depth,
        lastNodeId: data.last_node_id,

        replay: Boolean(replay.spectatingGame?.id)
      })
    } catch (ex) {
      console.log(ex)
      gameContext.utils.handleError();
    }
  }

  function PreloadBannerImages() {
    return <>
      {React.Children.toArray(
        loadingBeasts.map(beast =>
          <LazyLoadImage
            alt={""}
            height={1}
            src={fetch_card_image(beast)}
            width={1}
            onLoad={() => { setIsLoading(prev => prev + 1) }}
          />
        ))}
    </>
  }

  return (
    <Box sx={styles.container}>
      {isLoading < loadingBeasts.length && PreloadBannerImages()}

      <Box sx={styles.contentContainer}>
        <Box sx={styles.beastContainer}>
          {isLoading >= loadingBeasts.length && (
            <Box sx={styles.beastImageContainer}>
              <img
                alt={loadingBeasts[currentBeastIndex]}
                src={fetch_card_image(loadingBeasts[currentBeastIndex])}
                style={{
                  ...styles.beastImage,
                  animation: `pulse 4s infinite, ${fadeState} 0.5s ease-in-out`
                }}
              />
            </Box>
          )}
        </Box>

        <Box sx={styles.textContainer}>
          <Typography variant="h4" color="primary" sx={styles.loadingText}>
            Loading Game
          </Typography>

          <Box display={'flex'} alignItems={'baseline'}>
            {!tokenData.gameStarted ?
              <Typography variant="body1" color="white" sx={styles.loadingSubtext}>
                {loadingProgress === 0 && 'Awakening The Beasts'}
                {loadingProgress >= 1 && loadingProgress < 50 && 'Minting Game Token'}
                {loadingProgress >= 50 && loadingProgress < 70 && 'Fetching Game Settings'}
                {loadingProgress >= 70 && 'Shuffling Cards'}
              </Typography>
              : <Typography variant="body1" color="white" sx={styles.loadingSubtext}>
                Fetching Game Settings
              </Typography>
            }
            <div className='dotLoader white' />
          </Box>


        </Box>
      </Box>

      <Box sx={styles.progressContainer}>
        <LinearProgress
          variant="determinate"
          value={animatedProgress}
          sx={styles.progressBar}
        />
        <Typography variant="body2" color="primary" sx={styles.progressText}>
          {Math.round(animatedProgress)}%
        </Typography>
      </Box>
    </Box>
  )
}

export default LoadingContainer

const styles = {
  container: {
    width: '100%',
    height: '100%',
    boxSizing: 'border-box',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: '20px',
    background: 'linear-gradient(to bottom, rgba(0,0,0,0.8), rgba(0,0,0,0.6))',
    position: 'relative',
    overflow: 'hidden'
  },
  contentContainer: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    flex: 1,
    width: '100%',
    position: 'relative'
  },
  beastContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    height: '300px',
    width: '100%',
    position: 'relative'
  },
  beastImageContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    height: '100%',
    width: '100%'
  },
  beastImage: {
    height: '80%',
    maxWidth: '100%',
    objectFit: 'contain',
    filter: 'drop-shadow(0 0 10px rgba(255, 233, 127, 0.7))'
  },
  textContainer: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    marginTop: '20px',
    textAlign: 'center'
  },
  loadingText: {
    marginBottom: '10px',
    textShadow: '0 0 10px rgba(255, 233, 127, 0.7)',
    animation: 'glow 4s infinite'
  },
  loadingSubtext: {
    opacity: 0.8
  },
  progressContainer: {
    width: '80%',
    maxWidth: '600px',
    marginBottom: '40px',
    position: 'relative'
  },
  progressBar: {
    height: '10px',
    borderRadius: '5px',
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    '& .MuiLinearProgress-bar': {
      backgroundColor: '#FFE97F',
      borderRadius: '5px'
    }
  },
  progressText: {
    position: 'absolute',
    right: '0',
    top: '-20px',
    fontSize: '14px'
  }
}
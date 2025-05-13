import EastIcon from '@mui/icons-material/East';
import WestIcon from '@mui/icons-material/West';
import { Box, IconButton, LinearProgress, Typography } from '@mui/material';
import { motion } from "framer-motion";
import React, { useContext, useEffect, useState } from 'react';
import { Scrollbars } from 'react-custom-scrollbars';
import { BrowserView, MobileView, isMobile } from 'react-device-detect';
import BlockRevealAnimation from '../components/animations/blockRevealAnimation';
import HeroStats from '../components/draft/heroStats';
import Overview from '../components/draft/overview';
import Structure from '../components/map/structure';
import QuestComplete from '../components/map/questComplete';
import { BattleContext } from '../contexts/battleContext';
import { DojoContext } from '../contexts/dojoContext';
import { GameContext } from '../contexts/gameContext';
import { fadeVariant } from "../helpers/variants";

function MapContainer() {
  const dojo = useContext(DojoContext)
  const game = useContext(GameContext)
  const battle = useContext(BattleContext)

  const [cardOverview, setCardOverview] = useState(false)
  const [selectingNode, setSelectingNode] = useState(false)

  const [questProgress, setQuestProgress] = useState(0);

  useEffect(() => {
    if (game.values.questTarget) {
      setQuestProgress((Math.min(game.values.heroXp, game.values.questTarget) / game.values.questTarget) * 100);
    }
  }, [game.values.heroXp, game.values.questTarget]);

  useEffect(() => {
    if (game.values.questTarget && game.values.heroXp >= game.values.questTarget) {
      return
    }

    if (game.values.mapDepth === 0 && !game.values.replay) {
      game.actions.generateMap()
    }
  }, [game.values.mapDepth])

  const selectNode = async (nodeId) => {
    if (game.values.replay) {
      return
    }

    setSelectingNode(true)
    const res = await dojo.executeTx([{ contractName: "game_systems", entrypoint: "select_node", calldata: [game.values.gameId, nodeId] }], true)

    if (res) {
      const gameValues = res.find(e => e.componentName === 'Game')
      const battleValues = res.find(e => e.componentName === 'Battle')
      const battleResourcesValues = res.find(e => e.componentName === 'BattleResources')

      game.setGame(gameValues)
      battle.actions.startBattle(battleValues, battleResourcesValues)
    }

    setSelectingNode(false)
  }

  function renderQuest() {
    return (
      <Box sx={styles.questContainer}>
        <Box sx={styles.questContent}>
          <Typography variant="caption" sx={styles.questLabel}>
            QUEST PROGRESS
          </Typography>
          <Box sx={styles.progressContainer}>
            <LinearProgress
              variant="determinate"
              value={questProgress}
              sx={styles.progressBar}
            />
            <Typography variant="caption" sx={styles.questText}>
              {Math.min(game.values.heroXp, game.values.questTarget)}/{game.values.questTarget} XP
            </Typography>
          </Box>
        </Box>
      </Box>
    )
  }

  return (
    <motion.div style={styles.container} variants={fadeVariant} initial='initial' exit='exit' animate='enter'>
      <Box sx={styles.container}>

        {questProgress < 100
          ? <Box sx={isMobile ? styles.mobileDraftContainer : styles.draftContainer}>

            {(game.values.mapDepth === 0)
              ? <Box mt={10}><BlockRevealAnimation icon /></Box>
              : <Structure selectNode={selectNode} selectingNode={selectingNode} />
            }

          </Box>
          : <Box sx={isMobile ? styles.mobileDraftContainer : styles.draftContainer}>
            <QuestComplete />
          </Box>
        }

        <BrowserView>
          <Box sx={styles.overview}>
            <Scrollbars style={{ width: '100%', height: '100%' }}>
              {game.values.questTarget && renderQuest()}

              <HeroStats />

              <Overview />

            </Scrollbars>
          </Box>
        </BrowserView>

        <MobileView>
          {!cardOverview && <Box sx={styles.mobileOverview} width={'55px'} gap={2}>

            <IconButton onClick={() => setCardOverview(true)}>
              <WestIcon htmlColor='white' />
            </IconButton>

            <HeroStats compact={true} />

          </Box>}

          {cardOverview && <Box sx={styles.mobileOverview} width={'300px'}>
            <Scrollbars style={{ width: '100%', height: '100%' }}>

              <IconButton onClick={() => setCardOverview(false)} sx={{ ml: 1 }}>
                <EastIcon htmlColor='white' />
              </IconButton>

              {game.values.questTarget && renderQuest()}

              <HeroStats />

              <Overview />

            </Scrollbars>
          </Box>}
        </MobileView>

      </Box>
    </motion.div>
  )
}

export default MapContainer

const styles = {
  container: {
    width: '100%',
    height: '100%',
    display: 'flex'
  },

  overview: {
    width: '300px',
    height: 'calc(100vh - 55px)',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'space-between'
  },

  mobileOverview: {
    height: 'calc(100vh - 55px)',
    pt: '40px',
    display: 'flex',
    flexDirection: 'column',
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },

  draftContainer: {
    height: 'calc(100% - 55px)',
    width: 'calc(100% - 300px)',
    borderRight: '1px solid rgba(255, 255, 255, 0.12)',
    overflow: 'auto',
    boxSizing: 'border-box',
  },

  mobileDraftContainer: {
    height: '100%',
    width: 'calc(100% - 50px)',
    borderRight: '1px solid rgba(255, 255, 255, 0.12)',
    overflow: 'auto',
    boxSizing: 'border-box',
  },

  questContainer: {
    display: 'flex',
    alignItems: 'center',
    background: 'rgba(0, 0, 0, 0.2)',
    borderRadius: '5px',
    padding: '4px 12px',
    m: '8px',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    transition: 'all 0.3s ease',
  },
  questContent: {
    display: 'flex',
    flexDirection: 'column',
    width: '100%',
  },
  questLabel: {
    color: '#ffdd28',
    fontWeight: 'bold',
    letterSpacing: '1px',
    fontSize: '12px',
  },
  progressContainer: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    width: '100%',
  },
  progressBar: {
    flex: 1,
    height: '6px',
    borderRadius: '3px',
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    '& .MuiLinearProgress-bar': {
      background: 'linear-gradient(90deg, #FFD700 0%, #FFA500 100%)',
      borderRadius: '3px',
      transition: 'transform 0.5s ease-in-out',
    },
  },
  questText: {
    color: 'white',
    fontWeight: 'bold',
    fontSize: '12px',
    minWidth: '60px',
    textAlign: 'right',
  }
}
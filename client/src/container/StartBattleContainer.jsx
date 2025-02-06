import EastIcon from '@mui/icons-material/East';
import WestIcon from '@mui/icons-material/West';
import { Box, IconButton } from '@mui/material';
import { motion } from "framer-motion";
import React, { useContext, useEffect, useState } from 'react';
import { Scrollbars } from 'react-custom-scrollbars';
import { BrowserView, MobileView, isMobile } from 'react-device-detect';
import BlockRevealAnimation from '../components/animations/blockRevealAnimation';
import HeroStats from '../components/draft/heroStats';
import Overview from '../components/draft/overview';
import Structure from '../components/gametree/structure';
import { BattleContext } from '../contexts/battleContext';
import { GameContext } from '../contexts/gameContext';
import { LAST_NODE_LEVEL } from '../helpers/constants';
import { fadeVariant } from "../helpers/variants";
import { DojoContext } from '../contexts/dojoContext';
import { useReplay } from '../contexts/replayContext';

function StartBattleContainer() {
  const dojo = useContext(DojoContext)
  const game = useContext(GameContext)
  const battle = useContext(BattleContext)
  const replay = useReplay();

  const [cardOverview, setCardOverview] = useState(false)
  const [selectingNode, setSelectingNode] = useState(false)

  useEffect(() => {
    if (game.values.mapDepth === LAST_NODE_LEVEL && !game.values.replay) {
      game.actions.generateMap()
    }
  }, [game.values.mapDepth])

  const selectNode = async (nodeId) => {
    if (game.values.replay) {
      return
    }

    setSelectingNode(true)
    const res = await dojo.executeTx([{ contractName: "map_systems", entrypoint: "select_node", calldata: [game.values.gameId, nodeId] }], true)

    if (res) {
      const gameValues = res.find(e => e.componentName === 'Game')
      const battleValues = res.find(e => e.componentName === 'Battle')

      game.setGame(gameValues)
      battle.actions.startBattle(battleValues)
    }

    setSelectingNode(false)
  }

  return (
    <motion.div style={styles.container} variants={fadeVariant} initial='initial' exit='exit' animate='enter'>
      <Box sx={styles.container}>

        <Box sx={isMobile ? styles.mobileDraftContainer : styles.draftContainer}>

          {(game.values.mapDepth === LAST_NODE_LEVEL)
            ? <Box mt={10}><BlockRevealAnimation icon /></Box>
            : <Structure selectNode={selectNode} selectingNode={selectingNode} />
          }

        </Box>

        <BrowserView>
          <Box sx={styles.overview}>
            <Scrollbars style={{ width: '100%', height: '100%' }}>

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

          {cardOverview && <Box sx={styles.mobileOverview} width={'280px'}>
            <Scrollbars style={{ width: '100%', height: '100%' }}>

              <IconButton onClick={() => setCardOverview(false)} sx={{ ml: 1 }}>
                <EastIcon htmlColor='white' />
              </IconButton>

              <HeroStats />

              <Overview />

            </Scrollbars>
          </Box>}
        </MobileView>

      </Box>
    </motion.div>
  )
}

export default StartBattleContainer

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
  }
}
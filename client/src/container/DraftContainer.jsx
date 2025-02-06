import EastIcon from '@mui/icons-material/East';
import WestIcon from '@mui/icons-material/West';
import { Box, IconButton, Typography } from '@mui/material';
import { motion } from "framer-motion";
import React, { useContext, useState } from 'react';
import { isMobile } from 'react-device-detect';
import BlockRevealAnimation from '../components/animations/blockRevealAnimation';
import Card from '../components/card';
import DraftStats from '../components/draft/draftStats';
import Overview from '../components/draft/overview';
import { DraftContext } from '../contexts/draftContext';
import { GameContext } from '../contexts/gameContext';
import { useReplay } from '../contexts/replayContext';
import { CardSize } from '../helpers/cards';
import { fadeChildrenContainer, fadeChildrenItem } from '../helpers/variants';

function DraftContainer() {
  const replay = useReplay()

  const game = useContext(GameContext)
  const { gameSettings } = game.getState

  const draft = useContext(DraftContext)
  const { pendingCard, options, cards } = draft.getState

  const [cardOverview, setCardOverview] = useState(false)

  const selectCard = (index) => {
    if (pendingCard !== undefined) return;

    draft.actions.selectCard(index)
  }

  if (isMobile) {
    return <Box sx={[styles.container]}>

      <Box sx={styles.mobileDraftContainer}>

        <Box sx={styles.mobileMainContainer}>
          {options.length > 0
            ? <>
              {pendingCard !== undefined
                ? <Box display={'flex'} alignItems={'baseline'}>
                  <Typography variant='h3' color='primary'>
                    Selecting Card
                  </Typography>
                  <div className='dotLoader' style={{ width: '24px' }} />
                </Box>
                : <Typography variant='h3' color='primary'>
                  Select Card
                </Typography>
              }

              <motion.div key={cards.length} style={styles.cards} variants={fadeChildrenContainer} initial="hidden" animate="visible">
                {React.Children.toArray(
                  options.map((card, index) =>
                    <motion.div style={styles.mobileCardContainer}
                      onClick={() => selectCard(index)}
                      variants={fadeChildrenItem}>
                      <Card card={card} pendingCard={pendingCard} draftIndex={index} replaySelection={replay.getDraftCardSelection()} />
                    </motion.div>
                  ))}
              </motion.div>
            </>
            : <BlockRevealAnimation icon />
          }
        </Box>

      </Box>

      {!cardOverview && <Box sx={styles.mobileOverview}>

        <IconButton onClick={() => setCardOverview(true)}>
          <WestIcon htmlColor='white' />
        </IconButton>

        <Typography color='primary'>{cards.length}</Typography>
        <Typography color={'primary'}>/</Typography>
        <Typography color='primary'>{gameSettings.draft_size}</Typography>
      </Box>}

      {cardOverview && <Box sx={[styles.mobileOverview, { width: '260px', gap: 0 }]}>
        <IconButton onClick={() => setCardOverview(false)}>
          <EastIcon htmlColor='white' />
        </IconButton>

        <Overview />
      </Box>}

    </Box>
  }

  return (
    <Box sx={styles.container}>

      <Box sx={styles.draftContainer}>

        <Box sx={styles.mainContainer}>
          {options.length > 0
            ? <>
              {pendingCard !== undefined
                ? <Box display={'flex'} alignItems={'baseline'}>
                  <Typography variant='h2' color='primary'>
                    Selecting Card
                  </Typography>
                  <div className='dotLoader' style={{ width: '24px' }} />
                </Box>
                : <Typography variant='h2' color='primary'>
                  Select Card
                </Typography>
              }

              <motion.div key={cards.length} style={styles.cards} variants={fadeChildrenContainer} initial="hidden" animate="visible">
                {React.Children.toArray(
                  options.map((card, index) =>
                    <motion.div style={styles.cardContainer}
                      onClick={() => selectCard(index)}
                      variants={fadeChildrenItem}>
                      <Card card={card} pendingCard={pendingCard} draftIndex={index} replaySelection={replay.getDraftCardSelection()} />
                    </motion.div>
                  ))}
              </motion.div>
            </>
            : <BlockRevealAnimation icon />
          }
        </Box>

        <Box sx={styles.draftInfo}>
          <DraftStats />
        </Box>

      </Box>

      <Box sx={styles.overview}>
        <Overview />
      </Box>

    </Box>
  )
}

export default DraftContainer

const styles = {
  container: {
    width: '100%',
    height: '100%',
    display: 'flex'
  },

  overview: {
    width: '300px',
    height: '100%'
  },

  mobileOverview: {
    width: '50px',
    height: '100%',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: 1,
    boxSizing: 'border-box',
    pt: '40px',
    position: 'fixed',
    right: 0,
    background: 'rgba(0, 0, 0, 1)',
    zIndex: 100
  },

  mobileDraftContainer: {
    height: '100%',
    width: 'calc(100vw - 50px)',
  },

  draftContainer: {
    height: '100%',
    width: 'calc(100% - 300px)',
    borderRight: '1px solid rgba(255, 255, 255, 0.12)'
  },

  mobileMainContainer: {
    width: '100%',
    display: 'flex',
    flexDirection: 'column',
    gap: 2,
    py: 3,
    alignItems: 'center',
    justifyContent: 'flex-start',
    boxSizing: 'border-box'
  },

  mainContainer: {
    width: '100%',
    height: 'calc(100% - 285px)',
    minHeight: '420px',
    borderBottom: '1px solid rgba(255, 255, 255, 0.12)',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: window.innerHeight < 750 ? 2 : 5,
    pt: window.innerHeight < 750 ? 2 : 5,
    boxSizing: 'border-box'
  },

  cards: {
    display: 'flex',
    gap: 3,
    alignItems: 'center',
    justifyContent: 'center',
    flexWrap: 'wrap'
  },

  draftInfo: {
    maxHeight: 'calc(100% - 475px)',
    height: '230px',
    width: '100%'
  },

  cardContainer: {
    height: CardSize.big.height,
    width: CardSize.big.width,
    margin: '0 12px'
  },

  mobileCardContainer: {
    height: CardSize.big.height,
    width: CardSize.big.width,
    margin: '0 12px 12px'
  }
}
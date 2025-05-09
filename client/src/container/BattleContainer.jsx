import FavoriteIcon from '@mui/icons-material/Favorite';
import RestartAltIcon from '@mui/icons-material/RestartAlt';
import { LoadingButton } from '@mui/lab';
import { Box, Typography, IconButton } from '@mui/material';
import { motion } from "framer-motion";
import React, { useContext } from 'react';
import { isMobile } from 'react-device-detect';
import bolt from "../assets/images/bolt.png";
import cards from "../assets/images/cards.png";
import Battlefield from '../components/battle/battlefield';
import Deck from '../components/battle/deck';
import GameEffects from '../components/battle/gameEffects';
import Hand from '../components/battle/hand';
import { BattleContext } from '../contexts/battleContext';
import { CustomTooltip } from '../helpers/styles';
import { fadeVariant } from "../helpers/variants";

function BattleContainer() {
  const battle = useContext(BattleContext)

  const anyActionsLeft = battle.state.hand.find(card => battle.utils.getCardCost(card) <= battle.state.values.heroEnergy)

  const ResetButton = () => {
    return <Box sx={{ position: 'absolute', left: '10px', top: isMobile ? '40px' : '20px' }}>
      <CustomTooltip title="Reset Turn" position='right'>
        <IconButton
          onClick={() => battle.utils.undoBattleActions()}
          sx={{
            bgcolor: 'rgba(0, 0, 0, 0.5)',
            '&:hover': { bgcolor: 'rgba(0, 0, 0, 0.7)' }
          }}
        >
          <RestartAltIcon color='primary' />
        </IconButton>
      </CustomTooltip>
    </Box>

  }

  if (isMobile) {
    return <Box style={styles.mobileContainer}>
      <Box style={styles.mobileBoard}>
        <ResetButton />
        <Battlefield />
      </Box>

      <Box sx={{ width: '100%', display: 'flex', justifyContent: 'space-between', height: '30px', boxSizing: 'border-box', px: 2, mb: 2 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', width: '100px' }}>
          <Typography variant="h5">
            {battle.state.deck.length}
          </Typography>

          <img alt='' src={cards} height={21} />
        </Box>

        <Box sx={{ display: 'flex', gap: 0.5, justifyContent: 'center' }}>
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <Typography variant="h5">
              {battle.state.values.heroEnergy}
            </Typography>

            <img alt='' src={bolt} height={21} />
          </Box>

          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <Typography variant="h5">
              {battle.state.values.heroHealth}
            </Typography>

            <FavoriteIcon htmlColor="red" fontSize='small' />
          </Box>
        </Box>

        <GameEffects />
      </Box>

      <Box sx={[styles.playerContainer, { px: 0.5, height: isMobile ? '20%' : '25%' }]}>

        <Box sx={[styles.hand, { flex: 1 }]}>
          <Hand />
        </Box>

      </Box>
    </Box>
  }

  return (
    <motion.div style={styles.container} variants={fadeVariant} initial='initial' exit='exit' animate='enter'>
      <Box sx={styles.container}>

        <Box sx={styles.board}>

          <ResetButton />

          <Battlefield />

          <Box sx={{ position: 'absolute', right: '20px' }}>
            <CustomTooltip title={<Box mb={1}>
              <Typography color="primary">End Turn</Typography>
              <Typography mt={0.5}>- Your creatures attack.<br />- Monster perform its ability and attack.<br />- You replenish energy.</Typography>
            </Box>
            }>
              <LoadingButton variant='outlined' size='large' sx={[styles.endTurnButton, { opacity: anyActionsLeft ? 0.8 : 1, animation: anyActionsLeft ? '' : 'animateGlowSmall 2s linear infinite' }]}
                loading={battle.state.pendingTx}
                onClick={() => battle.actions.endTurn()}
              >
                End Turn
              </LoadingButton>
            </CustomTooltip>
          </Box>
        </Box>

        <Box sx={[styles.playerContainer, { height: '144px' }]}>

          <GameEffects />

          <Box sx={[styles.hand, { width: '800px' }]}>

            <Hand />

          </Box>

          <Box width={'232px'} display={'flex'} justifyContent={'center'}>

            <CustomTooltip title={
              <Box mb={1}>
                <Typography color="primary" variant='h6'>Deck</Typography>
                <Typography mt={0.5}>You draw a random card at the start of each turn.</Typography>
              </Box>
            }>
              <Deck />
            </CustomTooltip>

          </Box>

        </Box>

      </Box >
    </motion.div>
  )
}

export default BattleContainer

const styles = {
  container: {
    width: '100%',
    height: '100%',
    overflow: 'hidden'
  },

  mobileContainer: {
    width: '100vw',
    height: '100vh',
    overflow: 'hidden'
  },

  mobileBoard: {
    height: '70%',
    width: '100%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 2,
  },

  board: {
    height: 'calc(100% - 200px)',
    width: '100%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 2,
  },

  playerContainer: {
    width: '100%',
    display: 'flex',
    justifyContent: 'space-between',
    position: 'relative',
    px: 2,
    alignItems: 'center',
    boxSizing: 'border-box'
  },

  hand: {
    height: '100%',
  },

  utContainer: {
    height: '100%',
    display: 'flex',
    alignItems: 'center',
    pr: 2,
    gap: 3
  },

  deck: {
    background: '#141920',
    border: '1px solid rgba(255, 255, 255, 0.6)',
    height: '80px',
    width: '60px',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: '4px',
    boxShadow: `rgba(255, 233, 127, 0.35) 0px 5px 15px`,
    animation: 'animateGlowSmall 2s linear infinite',
    cursor: 'pointer'
  },

  cardCount: {
    width: '32px',
    height: '32px',
    borderRadius: '100%',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    border: '1px solid rgba(255, 255, 255, 0.3)',
  },

  kingContainer: {
    width: '100%',
    height: '20%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center'
  },

  endTurnButton: {
    fontSize: '16px',
    letterSpacing: '1px',
  }
}

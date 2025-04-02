import React, { useContext, useEffect, useState } from 'react'

import { motion } from "framer-motion"

import { Box, Drawer, Typography } from '@mui/material'
import { BattleContext } from '../../contexts/battleContext'
import { CardSize } from '../../helpers/cards'
import SmallCard from '../smallCard'
import Overview from '../draft/overview'
import Scrollbars from 'react-custom-scrollbars'

function Deck() {
  const battle = useContext(BattleContext)
  const { deck, newHandCards } = battle.state

  const [drawCard, setDrawCard] = useState(false)
  const [deckList, showDeckList] = useState()

  useEffect(() => {
    if (newHandCards.length > 0 && !drawCard) {
      setDrawCard(true)
    }
  }, [newHandCards])

  const afterDrawAnimation = () => {
    setDrawCard(false)
    battle.utils.setHand(prev => [...prev, newHandCards[0]])
    battle.utils.setNewHandCards(prev => prev.slice(1))
  }

  const renderDrawCard = () => {
    const cardPosition = `30px`

    return (
      <motion.div
        style={{
          ...styles.drawCardContainer,
          bottom: cardPosition,
          left: '90%',
        }}
        animate={{
          left: ['90%', '76%', '76%', '76%', '61%'],
          bottom: [cardPosition, cardPosition, cardPosition, cardPosition, '-80px'],
          width: [CardSize.small.width, CardSize.medium.width, CardSize.medium.width, CardSize.medium.width, CardSize.medium.width],
          height: [CardSize.small.height, CardSize.medium.height, CardSize.medium.height, CardSize.medium.height, CardSize.medium.height],
        }}
        transition={{ duration: 1.5, times: [0, 0.3, 0.5, 0.8, 1] }}
        onAnimationComplete={afterDrawAnimation}
      >
        <motion.div
          style={{ ...styles.drawCardInner }}
          animate={{
            rotateY: 180,
          }}
          transition={{ duration: 0.2 }}
        >
          <Box sx={{ ...styles.cardBack, ...styles.cardStyle }} />
          <Box sx={{ ...styles.cardFront, ...styles.cardStyle }}>

            <SmallCard card={newHandCards[0]} showStats={true} />

          </Box>
        </motion.div>
      </motion.div>
    )
  }

  return (
    <>
      <Box sx={styles.deck} onClick={() => showDeckList(true)}>
        <Box sx={styles.cardCount}>
          <Typography>
            {deck.length}
          </Typography>
        </Box>
      </Box>

      {drawCard && renderDrawCard()}

      <Drawer open={deckList} onClose={() => showDeckList(false)}>
        <Typography variant='h6' textAlign='center' color='primary' mt={1}>
          Deck
        </Typography>

        <Scrollbars style={{ width: '300px', height: '100%' }}>
          <Overview deck={deck} />
        </Scrollbars>
      </Drawer>
    </>
  )
}

export default Deck;

const styles = {
  card: {
    position: 'absolute',
    height: CardSize.medium.height,
    width: CardSize.medium.width,
    backgroundColor: 'brown',
    boxShadow: '0px 3px 1px -2px rgba(0,0,0,0.2), 0px 2px 2px 0px rgba(0,0,0,0.14), 0px 1px 5px 0px rgba(0,0,0,0.12)'
  },
  cardStyle: {
    boxShadow: '0px 3px 1px -2px rgba(0,0,0,0.2), 0px 2px 2px 0px rgba(0,0,0,0.14), 0px 1px 5px 0px rgba(0,0,0,0.12)',
    transition: 'box-shadow 300ms cubic-bezier(0.4, 0, 0.2, 1) 0ms',
    borderRadius: '4px',
    backfaceVisibility: 'hidden',
    width: '100%',
    height: '100%',
    position: 'absolute',
  },
  drawCardContainer: {
    backgroundColor: 'transparent',
    height: CardSize.medium.height,
    width: CardSize.medium.width,
    perspective: '1000px',
    position: 'fixed'
  },
  drawCardInner: {
    position: 'relative',
    width: '100%',
    height: '100%',
    transition: 'transform 1s',
    transformStyle: 'preserve-3d'
  },
  cardBack: {
    backgroundColor: '#141920',
    border: '1px solid rgba(255, 255, 255, 0.24)',
  },
  cardFront: {
    backgroundColor: 'white',
    transform: 'rotateY(180deg)',
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
}
import { Box, Typography } from "@mui/material";
import { motion } from "framer-motion";
import React, { useContext, useState } from "react";
import { isMobile } from 'react-device-detect';
import { DraftContext } from "../../contexts/draftContext";
import { CardSize, fetch_card_image } from "../../helpers/cards";
import { uniquefy } from '../../helpers/utilities';
import Card from "../card";

function Overview() {
  const draft = useContext(DraftContext)
  const { cards } = draft.getState

  const [displayCard, setDisplayCard] = useState(null)

  const uniqueCards = uniquefy(cards, "cardId")

  return <Box sx={styles.container}>

    {React.Children.toArray(
      uniqueCards.sort((a, b) => a.cost - b.cost).map(card => {
        const count = cards.filter(c => c.cardId === card.cardId).length

        return <motion.div style={{ ...styles.card }}
          onHoverStart={() => setDisplayCard(card)}
          onHoverEnd={() => setDisplayCard(null)}>

          <Box display={'flex'} gap={1} height={'100%'} alignItems={'center'}>
            <Box sx={styles.cardCost}>
              <Typography lineHeight={0}>
                {card.cost}
              </Typography>
            </Box>
            <Box height={'90%'}>
              <img alt='' src={fetch_card_image(card.name)} height={'100%'} />
            </Box>

            <Typography>
              {card.name}
            </Typography>
          </Box>

          <Box sx={styles.count}>
            <Typography color='primary'>
              {count > 1 && count}
            </Typography>
          </Box>

        </motion.div>
      })
    )}

    {displayCard && <Box sx={isMobile ? styles.mobileDisplayCard : styles.displayCard}>
      <Card card={displayCard} />
    </Box>}
  </Box>
}

export default Overview

const styles = {
  container: {
    display: 'flex',
    flexDirection: 'column',
    gap: 0.5,
    p: 1,
    width: '100%',
    boxSizing: 'border-box'
  },
  cardCost: {
    width: '20px',
    height: '20px',
    borderRadius: '24px',
    border: '1px solid #FFE97F',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },
  card: {
    overflow: 'hidden',
    boxSizing: 'border-box',
    width: '100%',
    height: '36px',
    background: '#141920',
    border: '1px solid rgba(255, 255, 255, 0.24)',
    borderRadius: '4px',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: '0 8px',
    cursor: 'pointer',
    transition: '0.3s',
    '&:hover': {
      border: '1px solid rgba(255, 255, 255, 0.6)',
    },
  },
  mobileDisplayCard: {
    zIndex: 1000,
    height: CardSize.large.height,
    width: CardSize.large.width,
    position: 'fixed',
    top: 45,
  },
  displayCard: {
    zIndex: 1000,
    height: CardSize.big.height,
    width: CardSize.big.width,
    position: 'fixed',
    right: '305px'
  },
  levelContainer: {
    marginTop: '-5px',
    marginRight: '-8px',
    position: 'relative',
  }
}
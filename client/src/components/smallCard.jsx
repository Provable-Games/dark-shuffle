import FavoriteIcon from '@mui/icons-material/Favorite';
import { Box, Typography } from "@mui/material";
import React from "react";
import { isBrowser, isMobile } from 'react-device-detect';
import sword from '../assets/images/sword.png';
import { fetch_card_image, types } from "../helpers/cards";

function SmallCard(props) {
  const { card, showStats, cost, onHand, energy, played } = props
  const playable = onHand && cost <= energy

  return <Box sx={[styles.container, played && { border: '2px solid green' }]} gap={isMobile ? 0.5 : 1}>

    <Box sx={styles.header}>
      <Box sx={[styles.circle, { opacity: playable ? 1 : 0.5 }]} border={'1px solid #FFE97F'}>
        <Typography fontSize={isMobile && '12px'}>
          {cost ?? card.cost}
        </Typography>
      </Box>

      <Typography fontSize={isMobile && '11px'}>
        {card.name}
      </Typography>
    </Box>

    <Box sx={isBrowser ? styles.imageContainer : styles.imageContainerMobile}>
      <img alt='' src={fetch_card_image(card.name)} height={'100%'} />
    </Box>

    <Box sx={styles.bottomContainer}>
      {showStats &&
        <>
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <Typography variant="h6">
              {card.attack}
            </Typography>

            <img alt='' src={sword} height={24} width={24} />
          </Box>

          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <Typography variant="h6">
              {card.health}
            </Typography>

            <FavoriteIcon htmlColor="red" />
          </Box>
        </>}

      {isBrowser && card.cardType === types.SPELL &&
        <Typography textAlign={'center'} width={'100%'} color='primary'>
          Spell
        </Typography>
      }
    </Box>

  </Box>
}

export default SmallCard

const styles = {
  container: {
    boxSizing: 'border-box',
    width: '100%',
    height: '100%',
    background: '#141920',
    borderRadius: '4px',
    p: 1,
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'space-between',
    cursor: 'pointer',
    overflow: 'hidden',
    border: '1px solid rgba(255, 255, 255, 0.24)'
  },
  imageContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
    height: '50%'
  },
  imageContainerMobile: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
    height: '65%'
  },
  header: {
    display: 'flex',
    gap: 1.5,
    alignItems: 'center'
  },
  circle: {
    height: '24px',
    width: '24px',
    minWidth: '24px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: '100px'
  },
  bottomContainer: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    height: '63px',
    boxSizing: 'border-box'
  },
  playable: {
    border: '1px solid white',
  }
}

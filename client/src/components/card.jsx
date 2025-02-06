import BookmarkIcon from '@mui/icons-material/Bookmark';
import FavoriteIcon from '@mui/icons-material/Favorite';
import { Box, Typography } from "@mui/material";
import React from "react";
import { isMobile } from 'react-device-detect';
import bolt from "../assets/images/bolt.png";
import sword from '../assets/images/sword.png';
import { fetch_card_image, types } from "../helpers/cards";
import { tierColors } from '../helpers/constants';

function Card(props) {
  const { card, pendingCard, draftIndex, replaySelection } = props

  return <Box sx={[
    styles.container,
    { opacity: (pendingCard >= 0 && pendingCard !== draftIndex) ? 0.3 : 1 },
    (replaySelection !== undefined && replaySelection === draftIndex) && { border: '1px solid #FFE97F' }
  ]} p={isMobile ? 1 : 1.5} pt={isMobile ? 0.5 : 1.5}>

    <Box sx={styles.header}>
      <Box sx={{ display: 'flex', alignItems: 'center', }}>
        <Typography variant="h5" fontSize={isMobile && '14px'}>
          {card.cost}
        </Typography>

        <img alt='' src={bolt} height={20} style={{ marginLeft: '-1px' }} />
      </Box>

      <Typography noWrap fontSize={isMobile && '14px'} variant='h6'>
        {card.name}
      </Typography>

      <Box sx={isMobile ? styles.mobileLevelContainer : styles.levelContainer}>
        <BookmarkIcon htmlColor={tierColors[card.cardTier]} fontSize='large' />
      </Box>
    </Box>

    <Box sx={styles.imageContainer}>
      <img alt='' src={fetch_card_image(card.name)} height={'100%'} />
    </Box>

    <Box sx={styles.textContainer} p={isMobile ? '2px' : '4px'}>
      {card.cardType === types.CREATURE && <Typography sx={{ opacity: 1, width: '100%' }} textAlign={'center'} fontSize={isMobile ? '12px' : '13px'}>
        <span>{card.text.split(':')[0]}:</span>
        <span style={{ opacity: 0.7, fontSize: '13px' }}>{card.text.split(':')[1]}</span>
      </Typography>}

      {card.cardType === types.SPELL && <Typography sx={{ opacity: 1, width: '100%' }} textAlign={'center'} fontSize={isMobile ? '12px' : '13px'}>
        {card.text}
      </Typography>}
    </Box>

    {card.cardType === types.CREATURE && <Box sx={styles.bottomContainer}>
      <Box sx={{ display: 'flex', alignItems: 'center' }}>
        <Typography variant="h6" fontSize={isMobile && '14px'}>
          {card.attack}
        </Typography>

        {isMobile
          ? <img alt='' src={sword} height={20} width={20} />
          : <img alt='' src={sword} height={24} width={24} />
        }
      </Box>

      <Box>
        <Typography variant="subtitle1" fontSize={isMobile ? '13px' : '15px'}>
          {card.creatureType}
        </Typography>
      </Box>

      <Box sx={{ display: 'flex', alignItems: 'center' }}>
        <Typography variant="h6" fontSize={isMobile && '14px'}>
          {card.health}
        </Typography>

        {isMobile ? <FavoriteIcon htmlColor="red" fontSize='small' /> : <FavoriteIcon htmlColor="red" />}
      </Box>
    </Box>}

    {card.cardType === types.SPELL && <Box sx={[styles.bottomContainer, { justifyContent: 'center' }]}>
      <Typography variant="subtitle1" fontSize={isMobile ? '13px' : '15px'}>
        Spell
      </Typography>
    </Box>}

  </Box >
}

export default Card

const styles = {
  container: {
    position: 'relative',
    zIndex: 5,
    boxSizing: 'border-box',
    width: '100%',
    height: '100%',
    background: '#141920',
    border: '1px solid rgba(255, 255, 255, 0.24)',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'space-between',
    cursor: 'pointer',
    overflow: 'hidden',
    transition: '0.3s',
    borderRadius: '4px',
    '&:hover': {
      border: '1px solid rgba(255, 255, 255, 0.6)',
    },
  },
  imageContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
    height: '40%'
  },
  textContainer: {
    width: '100%',
    height: '33%',
    border: '1px solid #FFE97F70',
    borderRadius: '4px',
    boxSizing: 'border-box',
    display: 'flex',
    gap: 0.5,
    background: 'rgba(0, 0, 0, 0.3)'
  },
  title: {
    fontSize: '18px',
    textOverflow: 'ellipsis',
    overflow: 'hidden',
    display: '-webkit-box',
    WebkitBoxOrient: 'vertical',
    WebkitLineClamp: 2,
  },
  chip: {
    background: '#1F1E1F',
    border: '1px solid #FFE97F',
    borderRadius: '10px',
    padding: '2px 12px',
    display: 'flex'
  },
  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  bottomContainer: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    height: '24px'
  },
  circle: {
    width: '28px',
    height: '28px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: '100px'
  },
  levelContainer: {
    marginTop: '-25px',
    marginRight: '-10px',
    position: 'relative'
  },
  mobileLevelContainer: {
    marginTop: '-9px',
    marginRight: '-10px',
    position: 'relative'
  }
}
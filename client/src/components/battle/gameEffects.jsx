import FavoriteIcon from '@mui/icons-material/Favorite';
import { Box, Typography } from '@mui/material';
import React, { useContext } from 'react';
import cards from "../../assets/images/cards.png";
import bolt from "../../assets/images/bolt.png";
import beast from "../../assets/images/beast.png";
import hero from "../../assets/images/hero.png";
import { GameContext } from '../../contexts/gameContext';
import { fetchBeastTypeImage, tags } from '../../helpers/cards';
import { LargeCustomTooltip } from '../../helpers/styles';
import { isMobile } from 'react-device-detect';

export default function GameEffects() {
  const game = useContext(GameContext)
  const { gameEffects } = game.getState

  return <Box sx={isMobile ? styles.effectMobileContainer : styles.effectContainer}>

    {(gameEffects.allAttack > 0 || gameEffects.firstCreatureCost > 0 || gameEffects.firstAttack > 0 || gameEffects.firstHealth > 0)
      && <LargeCustomTooltip title={
        <Box p={0.5}>
          <Box mb={0.5}>
            <Typography color="primary">Beasts</Typography>
          </Box>

          {gameEffects.allAttack > 0 && <Typography sx={styles.effectText}>
            All beasts get +{gameEffects.allAttack} attack.
          </Typography>}

          {gameEffects.firstCreatureCost > 0 && <Typography sx={styles.effectText}>
            The first beast you play each turn costs {gameEffects.firstCreatureCost} less.
          </Typography>}

          {gameEffects.firstAttack > 0 && <Typography sx={styles.effectText}>
            The first beast you play each turn gets +{gameEffects.firstAttack} attack.
          </Typography>}

          {gameEffects.firstHealth > 0 && <Typography sx={styles.effectText}>
            The first beast you play each turn gets +{gameEffects.firstHealth} health.
          </Typography>}
        </Box>
      }>
        <Box sx={styles.effectCircle}>
          <img alt='' src={beast} height={16} />
        </Box>
      </LargeCustomTooltip>}

    {(gameEffects.magicalAttack > 0 || gameEffects.magicalHealth > 0) && <LargeCustomTooltip title={
      <Box p={0.5}>
        <Box mb={0.5}>
          <Typography color="primary">Magical Creatures</Typography>
        </Box>
        {gameEffects.magicalAttack > 0 && <Typography sx={styles.effectText}>Gets +{gameEffects.magicalAttack} attack when played.</Typography>}
        {gameEffects.magicalHealth > 0 && <Typography sx={styles.effectText}>Gets +{gameEffects.magicalHealth} health when played.</Typography>}
      </Box>
    }>
      <Box sx={styles.effectCircle}>
        {fetchBeastTypeImage(tags.MAGICAL, "#FFE97F")}
      </Box>
    </LargeCustomTooltip>}

    {(gameEffects.hunterAttack > 0 || gameEffects.hunterHealth > 0) && <LargeCustomTooltip title={
      <Box p={0.5}>
        <Box mb={0.5}>
          <Typography color="primary">Hunter Creatures</Typography>
        </Box>
        {gameEffects.hunterAttack > 0 && <Typography sx={styles.effectText}>Gets +{gameEffects.hunterAttack} attack when played.</Typography>}
        {gameEffects.hunterHealth > 0 && <Typography sx={styles.effectText}>Gets +{gameEffects.hunterHealth} health when played.</Typography>}
      </Box>
    }>
      <Box sx={styles.effectCircle}>
        {fetchBeastTypeImage(tags.HUNTER, "#FFE97F")}
      </Box>
    </LargeCustomTooltip>}

    {(gameEffects.bruteAttack > 0 || gameEffects.bruteHealth > 0) && <LargeCustomTooltip title={
      <Box p={0.5}>
        <Box mb={0.5}>
          <Typography color="primary">Brute Creatures</Typography>
        </Box>
        {gameEffects.bruteAttack > 0 && <Typography sx={styles.effectText}>Gets +{gameEffects.bruteAttack} attack when played.</Typography>}
        {gameEffects.bruteHealth > 0 && <Typography sx={styles.effectText}>Gets +{gameEffects.bruteHealth} health when played.</Typography>}
      </Box>
    }>
      <Box sx={styles.effectCircle} pr={0.5}>
        {fetchBeastTypeImage(tags.BRUTE, "#FFE97F")}
      </Box>
    </LargeCustomTooltip>}


    {gameEffects.cardDraw > 0 && <LargeCustomTooltip title={
      <Box p={0.5}>
        <Box mb={0.5}>
          <Typography color="primary">Draw</Typography>
        </Box>
        {gameEffects.cardDraw == 1 && <Typography sx={styles.effectText}>You draw an extra card.</Typography>}
        {gameEffects.cardDraw > 1 && <Typography sx={styles.effectText}>You draw {gameEffects.cardDraw} extra cards.</Typography>}
      </Box>
    }>
      <Box sx={styles.effectCircle}>
        <img alt='' src={cards} height={16} />
      </Box>
    </LargeCustomTooltip>}

    {(gameEffects.heroCardHeal > 0 || gameEffects.playCreatureHeal > 0) && <LargeCustomTooltip title={
      <Box p={0.5}>
        <Box mb={0.5}>
          <Typography color="primary">Health</Typography>
        </Box>

        {gameEffects.playCreatureHeal > 0 && <Typography sx={styles.effectText}>Heal {gameEffects.playCreatureHeal} when you play a creature.</Typography>}
        {gameEffects.heroCardHeal > 0 && <Typography sx={styles.effectText}>At the end of your turn, heal equal to the number of cards in your hand.</Typography>}
      </Box>
    }>
      <Box sx={styles.effectCircle}>
        <FavoriteIcon htmlColor='#ffb260' sx={{ fontSize: '16px' }} />
      </Box>
    </LargeCustomTooltip>}

    {gameEffects.startBonusEnergy > 0 && <LargeCustomTooltip title={
      <Box p={0.5}>
        <Box mb={0.5}>
          <Typography color="primary">Energy</Typography>
        </Box>
        {gameEffects.startBonusEnergy > 0 && <Typography sx={styles.effectText}>You start with +{gameEffects.startBonusEnergy} energy.</Typography>}
      </Box>
    }>
      <Box sx={styles.effectCircle}>
        <img alt='' src={bolt} height={16} />
      </Box>
    </LargeCustomTooltip>}

    {gameEffects.heroDmgReduction > 0 && <LargeCustomTooltip title={
      <Box p={0.5}>
        <Box mb={0.5}>
          <Typography color="primary">Hero</Typography>
        </Box>
        {gameEffects.heroDmgReduction > 0 && <Typography sx={styles.effectText}>
          Your hero takes {gameEffects.heroDmgReduction} less damage from all sources.
        </Typography>}
      </Box>
    }>
      <Box sx={styles.effectCircle}>
        <img alt='' src={hero} height={16} />
      </Box>
    </LargeCustomTooltip>}
  </Box >
}

const styles = {
  effectMobileContainer: {
    width: '100px',
    display: 'flex',
    justifyContent: 'flex-end',
    gap: 0.5,
    overflow: 'hidden'
  },

  effectContainer: {
    width: '232px',
    display: 'flex',
    gap: 1,
    flexWrap: 'wrap',
    mb: 1
  },

  effectCircle: {
    width: '30px',
    height: '30px',
    borderRadius: '50%',
    background: 'rgba(0, 0, 0, 0.6)',
    border: '1px solid #f59100',
    boxSizing: 'border-box',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    cursor: 'pointer',
    animation: 'animateGlowSmall 2s linear infinite',
  },

  effectText: {
    fontSize: '13px',
    color: '#ffb260',
  }
}

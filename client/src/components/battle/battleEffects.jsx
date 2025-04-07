import { Box, Typography } from '@mui/material';
import React, { useContext } from 'react';
import { BattleContext } from '../../contexts/battleContext';
import { fetchCardTypeImage, tags } from '../../helpers/cards';
import { LargeCustomTooltip } from '../../helpers/styles';

export default function BattleEffects() {
  const battle = useContext(BattleContext)
  const { battleEffects } = battle.state

  const circleStyle = styles.effectCircle

  return <Box sx={styles.effectContainer}>
    {(battleEffects?.nextMagicalAttackBonus > 0 || battleEffects?.nextMagicalHealthBonus > 0) &&
      <LargeCustomTooltip title={
        <Box p={0.5}>
          {battleEffects?.nextMagicalAttackBonus > 0 &&
            <Typography sx={styles.effectText}>
              Next magical creature gets +{battleEffects.nextMagicalAttackBonus} attack when played.
            </Typography>
          }
          {battleEffects?.nextMagicalHealthBonus > 0 &&
            <Typography sx={styles.effectText}>
              Next magical creature gets +{battleEffects.nextMagicalHealthBonus} health when played.
            </Typography>
          }
        </Box>
      }>
        <Box sx={circleStyle}>
          {fetchCardTypeImage(tags.MAGICAL, "#FFE97F")}
        </Box>
      </LargeCustomTooltip>
    }

    {(battleEffects?.nextHunterAttackBonus > 0 || battleEffects?.nextHunterHealthBonus > 0) &&
      <LargeCustomTooltip title={
        <Box p={0.5}>
          {battleEffects?.nextHunterAttackBonus > 0 &&
            <Typography sx={styles.effectText}>
              Next hunter creature gets +{battleEffects.nextHunterAttackBonus} attack when played.
            </Typography>
          }
          {battleEffects?.nextHunterHealthBonus > 0 &&
            <Typography sx={styles.effectText}>
              Next hunter creature gets +{battleEffects.nextHunterHealthBonus} health when played.
            </Typography>
          }
        </Box>
      }>
        <Box sx={circleStyle}>
          {fetchCardTypeImage(tags.HUNTER, "#FFE97F")}
        </Box>
      </LargeCustomTooltip>
    }

    {(battleEffects?.nextBruteAttackBonus > 0 || battleEffects?.nextBruteHealthBonus > 0) &&
      <LargeCustomTooltip title={
        <Box p={0.5}>
          {battleEffects?.nextBruteAttackBonus > 0 &&
            <Typography sx={styles.effectText}>
              Next brute creature gets +{battleEffects.nextBruteAttackBonus} attack when played.
            </Typography>
          }
          {battleEffects?.nextBruteHealthBonus > 0 &&
            <Typography sx={styles.effectText}>
              Next brute creature gets +{battleEffects.nextBruteHealthBonus} health when played.
            </Typography>
          }
        </Box>
      }>
        <Box sx={circleStyle} pr={0.5}>
          {fetchCardTypeImage(tags.BRUTE, "#FFE97F")}
        </Box>
      </LargeCustomTooltip>
    }
  </Box>
}

const styles = {
  effectContainer: {
    width: '100%',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: '5px',
  },

  effectCircle: {
    width: '28px',
    height: '28px',
    borderRadius: '50%',
    background: 'rgba(0, 0, 0, 0.6)',
    border: '1px solid #6f8000',
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
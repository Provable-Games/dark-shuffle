import FavoriteIcon from '@mui/icons-material/Favorite';
import { Box, Typography } from "@mui/material";
import { useLottie } from 'lottie-react';
import React, { useContext, useEffect, useState } from "react";
import healAnim from "../../assets/animations/heal.json";
import shieldAnim from "../../assets/animations/shield.json";
import bolt from "../../assets/images/bolt.png";
import monarch from "../../assets/images/monarch.png";
import shield from "../../assets/images/shield.png";
import { BattleContext } from '../../contexts/battleContext';
import { GameContext } from '../../contexts/gameContext';
import { CustomTooltip, EnergyBar, HealthBar } from '../../helpers/styles';
import { normalise } from '../../helpers/utilities';
import DamageAnimation from '../animations/damageAnimation';

export default function Adventurer(props) {
  const game = useContext(GameContext)
  const { gameSettings } = game.getState

  const battle = useContext(BattleContext)

  const [armor, setArmor] = useState(battle.state.battleEffects.heroDmgReduction ?? 0 + game.getState.gameEffects.heroDmgReduction ?? 0)
  const [health, setHealth] = useState(battle.state.values.heroHealth)
  const [damageTaken, setDamageTaken] = useState(0)

  const _shield = useLottie({
    animationData: shieldAnim,
    loop: false,
    autoplay: false,
    style: { position: 'absolute', width: '50px', height: '50px', top: '45px', left: '75px' },
    onComplete: () => _shield.stop()
  });

  const heal = useLottie({
    animationData: healAnim,
    loop: false,
    autoplay: false,
    style: { position: 'absolute', width: '100px', height: '100px', top: '20px', left: '50px' },
    onComplete: () => heal.stop()
  });

  useEffect(() => {
    if (health > battle.state.values.heroHealth) {
      setDamageTaken(health - battle.state.values.heroHealth)
      setHealth(battle.state.values.heroHealth)
    }

    if (health < battle.state.values.heroHealth) {
      heal.play()
      setHealth(battle.state.values.heroHealth)
    }
  }, [battle.state.values.heroHealth])

  useEffect(() => {
    if (battle.state.battleEffects.heroDmgReduction ?? 0 + game.getState.gameEffects.heroDmgReduction ?? 0 > armor) {
      _shield.play()
      setArmor(battle.state.battleEffects.heroDmgReduction ?? 0 + game.getState.gameEffects.heroDmgReduction ?? 0)
    }
  }, [battle.state.battleEffects.heroDmgReduction])

  return <Box sx={styles.king}>
    <DamageAnimation damage={damageTaken} mini={true} />

    {_shield.View}
    {heal.View}

    <img alt='' src={monarch} height={'70%'} />

    <Box sx={{ display: 'flex', flexDirection: 'column' }}>
      <Box sx={{ display: 'flex', alignItems: 'center' }}>
        <CustomTooltip title={
          <Box mb={1}>
            <Box sx={{ display: 'flex', alignItems: 'center' }}>
              <img alt='' src={bolt} height={20} />
              <Typography color="primary" variant='h6'>Energy</Typography>
            </Box>
            <Typography mt={0.5}>Cards require energy to play.</Typography>
            <Typography mt={0.5}>You replenish energy at the start of each turn.</Typography>
          </Box>
        }>
          <Box width={'80px'} display={'flex'} alignItems={'center'} justifyContent={'flex-end'}>
            <Typography>
              {battle.state.values.heroEnergy}
            </Typography>

            <img alt='' src={bolt} height={18} />
          </Box>
        </CustomTooltip>

        <Box width={'160px'} mx={0.5}>
          <EnergyBar variant="determinate" value={normalise(battle.state.values.heroEnergy, battle.state.values.round)} />
        </Box>

        <Typography mr={'50px'} sx={{ fontSize: '13px', opacity: 0.7 }}>
          +{Math.min(gameSettings.max_energy, battle.state.values.round + 1)}
        </Typography>
      </Box>

      <Box sx={{ display: 'flex', alignItems: 'center', position: 'relative' }}>
        <CustomTooltip title={
          <Box mb={1}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
              <FavoriteIcon htmlColor="red" fontSize='small' />

              <Typography color="primary" variant='h6'>Health</Typography>
            </Box>
            <Typography mt={0.5}>If your health reaches 0, the game ends.</Typography>
          </Box>
        }>
          <Box width={'80px'} display={'flex'} alignItems={'center'} justifyContent={'flex-end'}>
            <Typography>
              {battle.state.values.heroHealth}
            </Typography>

            <FavoriteIcon htmlColor="red" sx={{ fontSize: '18px' }} />
          </Box>
        </CustomTooltip>

        <Box width={'160px'} ml={0.5}>
          <HealthBar variant="determinate" value={normalise(battle.state.values.heroHealth, Math.max(gameSettings.starting_health, game.values.heroHealth))} />
        </Box>

        {armor > 0 && <Box display={'flex'} alignItems={'center'} ml={0.5}>
          <Typography>
            {armor}
          </Typography>

          <img alt='' src={shield} height={16} />
        </Box>}
      </Box>
    </Box>

  </Box >
}

const styles = {
  container: {
    boxSizing: 'border-box',
    width: '100%',
    height: '90%',
    borderRadius: '4px',
    background: 'rgba(0, 0, 0, 0.6)',
  },
  myContainer: {
    width: '100%',
    height: '35%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 2,
  },
  targetIcon: {
    width: '35px',
    height: '35px',
    position: 'absolute',
    top: '-25px',
    left: 'calc(50%-18px)',
  },
  king: {
    width: '200px',
    height: '100%',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    boxSizing: 'border-box',
    pt: 2,
    gap: 1.5,
    position: 'relative'
  }
}
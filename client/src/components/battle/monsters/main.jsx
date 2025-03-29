import FavoriteIcon from '@mui/icons-material/Favorite';
import { Box, Typography } from "@mui/material";
import { useLottie } from 'lottie-react';
import { motion } from "framer-motion";
import React, { useEffect, useState } from "react";
import { isMobile } from 'react-device-detect';
import healAnim from "../../../assets/animations/heal.json";
import sword from "../../../assets/images/sword.png";
import { fetch_card_image } from '../../../helpers/cards';
import { EnemyHealthBar } from '../../../helpers/styles';
import { normalise } from '../../../helpers/utilities';
import DamageAnimation from '../../animations/damageAnimation';

export default function MonsterMain(props) {
  const { monster } = props

  const [health, setHealth] = useState(monster.health)
  const [attack, setAttack] = useState(monster.attack)
  const [healthGlow, setHealthGlow] = useState(false)
  const [attackGlow, setAttackGlow] = useState(false)
  const [damageTaken, setDamageTaken] = useState(0)

  const heal = useLottie({
    animationData: healAnim,
    loop: false,
    autoplay: false,
    style: { width: '50px', height: '50px', position: 'absolute', right: '-7px', bottom: '-8px' },
    onComplete: () => heal.stop()
  });

  useEffect(() => {
    if (monster.health !== health) {
      setHealthGlow(monster.health > health ? 'green' : 'red')
      setTimeout(() => setHealthGlow(false), 1000)
      setHealth(monster.health)
    }

    if (monster.health < health) {
      setDamageTaken(health - monster.health)
    }

    else if (monster.health > health) {
      heal.play()
    }
  }, [monster.health])

  useEffect(() => {
    if (monster.attack !== attack) {
      setAttackGlow(monster.attack > attack ? 'green' : 'red')
      setTimeout(() => setAttackGlow(false), 1000)
      setAttack(monster.attack)
    }
  }, [monster.attack])

  return <>
    <EnemyHealthBar variant="determinate" value={normalise(health, monster.startHealth)} />

    {monster.health > 0 && <DamageAnimation damage={damageTaken} />}

    <Box sx={styles.imageContainer}>
      {<img alt='' src={fetch_card_image(monster.name)} height={'100%'} />}
    </Box>

    <Box sx={styles.bottomContainer}>
      <Box sx={{ display: 'flex', alignItems: 'center' }}>
        <motion.div
          animate={{
            textShadow: attackGlow
              ? `0 0 8px ${attackGlow === 'green' ? "rgba(0, 255, 0, 0.8)" : "rgba(255, 0, 0, 0.8)"}`
              : "none",
          }}
          transition={{ duration: 0.5, ease: 'easeInOut' }}
        >
          <Typography variant="h6" fontSize={isMobile && '14px'}>
            {monster.attack}
          </Typography>
        </motion.div>

        <motion.img
          alt=''
          src={sword}
          height={isMobile ? '20px' : '24px'}
          width={isMobile ? '20px' : '24px'}
          animate={{
            rotate: attackGlow ? [0, -20, 20, 0] : 0
          }}
          transition={{
            duration: 1,
          }}
        />
      </Box>

      <Box>
        <Typography variant="subtitle1" fontSize={isMobile ? '13px' : '14px'}>
          {monster.monsterType}
        </Typography>
      </Box>

      <Box sx={{ display: 'flex', alignItems: 'center' }}>
        <motion.div
          animate={{
            textShadow: healthGlow
              ? `0 0 8px ${healthGlow === 'green' ? "rgba(0, 255, 0, 0.8)" : "rgba(255, 0, 0, 0.8)"}`
              : "none",
          }}
          transition={{ duration: 0.5, ease: 'easeInOut' }}
        >
          <Typography variant="h6" fontSize={isMobile && '14px'}>
            {monster.health}
          </Typography>
        </motion.div>

        <FavoriteIcon htmlColor="red" fontSize={isMobile ? 'small' : 'small'} />
      </Box>
    </Box>
  </>
}

const styles = {
  imageContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
    height: '70%'
  },
  bottomContainer: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
}
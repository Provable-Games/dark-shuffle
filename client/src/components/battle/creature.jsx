import { Box, Typography } from "@mui/material";
import { motion, useAnimationControls } from "framer-motion";
import React, { useContext, useEffect, useState } from "react";
import { isMobile } from 'react-device-detect';
import sword from "../../assets/images/sword.png";
import FavoriteIcon from '@mui/icons-material/Favorite';
import { AnimationContext } from '../../contexts/animationHandler';
import { CardSize, fetch_card_image, fetchBeastTypeImage } from '../../helpers/cards';
import DamageAnimation from '../animations/damageAnimation';
import SleepAnimation from '../animations/sleepAnimation';
import skullAnim from "../../assets/animations/skull.json";
import healAnim from "../../assets/animations/heal.json";
import attackBonusAnim from "../../assets/animations/attack_bonus.json";
import attackMinusAnim from "../../assets/animations/attack_minus.json";
import Card from '../card';
import { BattleContext } from "../../contexts/battleContext";
import { useLottie } from "lottie-react";

let mobileSize = { width: '100px', height: '100px' }
let browserSize = { width: '120px', height: '120px' }

function Creature(props) {
  const { creature } = props

  const battle = useContext(BattleContext)
  const animationHandler = useContext(AnimationContext)

  const [displayCard, setDisplayCard] = useState(null)
  const [health, setHealth] = useState(creature.health)
  const [attack, setAttack] = useState(creature.attack)
  const [damageTaken, setDamageTaken] = useState(0)
  const [showAttackMinus, setShowAttackMinus] = useState(false)

  const controls = useAnimationControls()
  const skullControls = useAnimationControls()

  const skull = useLottie({
    animationData: skullAnim,
    loop: false,
    autoplay: false,
    style: isMobile ? mobileSize : browserSize,
    onComplete: () => skull.stop()
  });

  const heal = useLottie({
    animationData: healAnim,
    loop: false,
    autoplay: false,
    style: { width: '50px', height: '50px', position: 'absolute', right: '-7px', bottom: '-8px' },
    onComplete: () => heal.stop()
  });

  const attackMinus = useLottie({
    animationData: attackMinusAnim,
    loop: false,
    autoplay: false,
    style: { width: '30px', height: '30px', position: 'absolute', left: '18px', bottom: '1px', opacity: showAttackMinus ? 1 : 0 },
    onComplete: () => setShowAttackMinus(false)
  });

  const attackPlus = useLottie({
    animationData: attackBonusAnim,
    loop: false,
    autoplay: false,
    style: { width: '60px', height: '60px', position: 'absolute', left: '30px', bottom: '30px' },
    onComplete: () => attackPlus.stop()
  });

  const killCreature = async () => {
    battle.utils.creatureDeathEffect(creature)

    await skullControls.start({
      opacity: 0,
      transition: { duration: 1 }
    })

    battle.utils.setBoard(prev => prev.filter(c => c.id !== creature.id))
  }

  useEffect(() => {
    if (creature.dead) {
      killCreature()
      skull.play()
    }
  }, [creature.dead])

  useEffect(() => {
    if (creature.health < health) {
      setDamageTaken(health - creature.health)
      setHealth(creature.health)
    }

    if (creature.health > health) {
      heal.play()
      setHealth(creature.health)
    }
  }, [creature.health])

  useEffect(() => {
    if (creature.attack < attack) {
      setShowAttackMinus(true)
      attackMinus.play()
      setAttack(creature.attack)
    }

    if (creature.attack > attack) {
      attackPlus.play()
      setAttack(creature.attack)
    }
  }, [creature.attack])

  useEffect(() => {
    const creatureAnimation = animationHandler.creatureAnimations.find(anim => anim.creatureId === creature.id)

    if (creatureAnimation) {
      if (creatureAnimation.type === 'attack') {
        attackAnimation(creatureAnimation)
        animationHandler.setCreatureAnimations(prev => prev.filter(x => x.type === 'attack' && x.creatureId !== creature.id))
      }
    }
  }, [animationHandler.creatureAnimations])

  const attackAnimation = async (creatureAnimation) => {
    const { creature, position, targetPosition } = creatureAnimation

    await controls.start({
      x: targetPosition.x - position.x,
      y: position.y - targetPosition.y,
      zIndex: 1000
    })

    animationHandler.animationCompleted({ type: 'creatureAttack', creatureId: creature.id })

    await controls.start({
      x: 0,
      y: 0,
      rotate: 0,
      zIndex: 0
    })
  }

  const mouseUpHandler = (event) => {
  }

  return <Box sx={{ position: 'relative' }}>
    <motion.div animate={skullControls} style={{ ...styles.browserSize, display: creature.dead ? 'inherit' : 'none' }}>
      {skull.View}
    </motion.div>

    {!creature.dead && <motion.div
      style={isMobile ? { ...styles.mobileSize } : { ...styles.browserSize }}
      key={creature.id}
      layout
      layoutId={creature.id}
      animate={controls}
      onHoverStart={() => setDisplayCard(creature)}
      onHoverEnd={() => setDisplayCard(null)}
      onMouseUp={(event) => mouseUpHandler(event)}
    >

      <Box sx={[isMobile ? styles.mobileSize : styles.browserSize, styles.container, creature.resting && styles.faded]}>

        {creature.attacked && <SleepAnimation />}

        {heal.View}
        {attackMinus.View}
        {attackPlus.View}

        <DamageAnimation damage={damageTaken} small={true} />

        <Box sx={styles.typeContainer}>
          {fetchBeastTypeImage(creature.creatureType)}
        </Box>

        <Box sx={styles.imageContainer}>
          <img alt='' src={fetch_card_image(creature.name)} height={'100%'} />
        </Box>

        <Box sx={styles.bottomContainer}>
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <Typography variant="h6" fontSize={isMobile && '12px'}>
              {creature.attack}
            </Typography>

            <img alt='' src={sword} height={'18px'} width={'18px'} />
          </Box>

          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <Typography variant="h6" fontSize={isMobile && '12px'}>
              {creature.health}
            </Typography>

            <FavoriteIcon htmlColor="red" fontSize={'small'} sx={{ fontSize: '18px' }} />
          </Box>
        </Box>

      </Box>

    </motion.div>}

    {!creature.dead && displayCard && <Box sx={isMobile ? styles.displayCardMobile : styles.displayCard}>
      <Card card={displayCard} />
    </Box>}
  </Box>
}

export default Creature

const styles = {
  browserSize,
  mobileSize,
  container: {
    boxSizing: 'border-box',
    background: '#141920',
    border: '1px solid rgba(255, 255, 255, 0.6)',
    borderRadius: '4px',
    p: 1,
    pb: '2px',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'space-between',
    cursor: 'pointer',
    overflow: 'hidden',
    transition: '0.3s',
    '&:hover': {
      border: '1px solid rgba(255, 255, 255, 0.8)',
    },
  },
  imageContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
    height: '65%',
    mt: 0.5
  },
  bottomContainer: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  faded: {
    opacity: 0.9,
    border: '1px solid rgba(255, 255, 255, 0.2)',
    '&:hover': {
      border: '1px solid rgba(255, 255, 255, 0.2)',
    },
  },
  displayCard: {
    height: CardSize.big.height,
    width: CardSize.big.width,
    position: 'absolute',
    left: '136px',
    top: 0
  },
  displayCardMobile: {
    height: CardSize.big.height,
    width: CardSize.big.width,
    position: 'fixed',
    left: `${(window.innerWidth - 252) / 2}px`,
    top: '20px',
    zIndex: 2000
  },
  targetIcon: {
    width: '35px',
    height: '35px',
    position: 'absolute',
    top: '-40px',
    left: '42px',
  },
  highlight: {
    border: '1px solid #FFE97F !important',
  },
  typeContainer: {
    position: 'absolute',
    top: '5px',
    right: '5px',
  }
}
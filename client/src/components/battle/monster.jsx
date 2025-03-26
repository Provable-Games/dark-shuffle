import CrisisAlertIcon from '@mui/icons-material/CrisisAlert';
import { Box, Typography } from "@mui/material";
import { motion, useAnimationControls } from "framer-motion";
import { useLottie } from 'lottie-react';
import React, { useContext, useEffect, useRef } from "react";
import { isMobile } from 'react-device-detect';
import skullAnim from "../../assets/animations/skull.json";

import attackBonusAnim from "../../assets/animations/attack_bonus.json";
import attackMinusAnim from "../../assets/animations/attack_minus.json";
import healAnim from "../../assets/animations/heal.json";
import markEnemyAnim from "../../assets/animations/mark_enemy.json";

import { useState } from "react";
import { AnimationContext } from '../../contexts/animationHandler';
import { CustomTooltip } from "../../helpers/styles";
import { delay } from "../../helpers/utilities";
import DamageAnimation from '../animations/damageAnimation';
import * as Monsters from './monsters';
import { BattleContext } from '../../contexts/battleContext';

function Monster(props) {
  const battle = useContext(BattleContext)
  const animationHandler = useContext(AnimationContext)

  const { monster } = props

  const [health, setHealth] = useState(monster.health)
  const [attack, setAttack] = useState(monster.attack)
  const [marks, setMarks] = useState(battle.state.battleEffects?.enemyMarks ?? 0)

  const [damageTaken, setDamageTaken] = useState(0)
  const [showAttackMinus, setShowAttackMinus] = useState(false)

  const controls = useAnimationControls()
  const skullControls = useAnimationControls()
  const ref = useRef()

  const skull = useLottie({
    animationData: skullAnim,
    loop: false,
    autoplay: false,
    style: { ...(isMobile ? { height: '160px', width: '160px' } : { height: '200px', width: '200px' }), top: 0, position: 'absolute' },
    onComplete: () => skull.stop()
  });

  const heal = useLottie({
    animationData: healAnim,
    loop: false,
    autoplay: false,
    style: { ...(isMobile ? { height: '160px', width: '160px' } : { height: '200px', width: '200px' }), top: 0, position: 'absolute' },
    onComplete: () => heal.stop()
  });

  const attackMinus = useLottie({
    animationData: attackMinusAnim,
    loop: false,
    autoplay: false,
    style: { height: '80px', width: '80px', top: isMobile ? '40px' : '60px', right: isMobile ? '40px' : '60px', position: 'absolute', opacity: showAttackMinus ? 1 : 0 },
    onComplete: () => setShowAttackMinus(false)
  });

  const attackPlus = useLottie({
    animationData: attackBonusAnim,
    loop: false,
    autoplay: false,
    style: { ...(isMobile ? { height: '24px', width: '24px' } : { height: '24px', width: '24px' }), bottom: '10px', left: '24px', position: 'absolute', background: 'rgba(8, 8, 8, 1)' },
    onComplete: () => attackPlus.stop()
  });

  const markEnemy = useLottie({
    animationData: markEnemyAnim,
    loop: false,
    autoplay: false,
    initialSegment: [0, 40],
    style: { height: '120px', width: '120px', top: isMobile ? '20px' : '40px', right: isMobile ? '20px' : '40px', position: 'absolute' },
    onComplete: () => markEnemy.stop()
  });

  useEffect(() => {
    if (battle.state.battleEffects.enemyMarks > marks) {
      markEnemy.play()
      setMarks(battle.state.battleEffects.enemyMarks)
    }
  }, [battle.state.battleEffects.enemyMarks])

  useEffect(() => {
    if (monster.health <= 0) {
      fadeSkull()
      skull.play()
    }

    else if (monster.health < health) {
      setDamageTaken(health - monster.health)
      setHealth(monster.health)
    }

    else if (monster.health > health) {
      heal.play()
      setHealth(monster.health)
    }
  }, [monster.health])

  useEffect(() => {
    if (monster.attack < attack) {
      setShowAttackMinus(true)
      attackMinus.play()
      setAttack(monster.attack)
    }

    else if (monster.attack > attack) {
      attackPlus.play()
      setAttack(monster.attack)
    }
  }, [monster.attack])

  useEffect(() => {
    if (animationHandler.monsterAnimations.length < 1) {
      return
    }

    const animation = animationHandler.monsterAnimations[0]

    if (animation.type === 'attack') {
      attackAnimation(animation)
      animationHandler.setMonsterAnimations(prev => prev.filter(x => x.type !== 'attack'))
    }
  }, [animationHandler.monsterAnimations])

  const fadeSkull = async () => {
    await skullControls.start({
      opacity: 0,
      transition: { duration: 2, delay: 1 }
    })
  }

  const attackAnimation = async (animation) => {
    const { position, targetPosition } = animation
    await delay(500)

    ref.current.style.background = 'black'

    await controls.start({
      x: targetPosition.x - position.x,
      y: position.y - targetPosition.y,
      zIndex: 100,
    })

    controls.start({
      x: 0,
      y: 0,
      rotate: 0,
      zIndex: 0
    })


    ref.current.style.background = 'none'
    animationHandler.animationCompleted({ type: 'monsterAttack' })
  }

  let MonsterComponent = Monsters[monster.name]

  const mouseUpHandler = (event) => {
  }

  return <>
    <motion.div
      layout
      onMouseUp={(event) => mouseUpHandler(event)}
      animate={controls}
      ref={ref}
      style={isMobile ? { position: 'relative', width: '160px', height: '160px' } : { position: 'relative', width: '200px', height: '200px' }}
    >

      {monster.health > 0 && <DamageAnimation damage={damageTaken} />}

      <motion.div animate={skullControls} style={{ left: isMobile ? 'calc(50% - 80px)' : 'calc(50% - 100px)', top: 0, position: 'absolute', opacity: monster.health > 0 ? 0 : 1 }}>
        {skull.View}
      </motion.div>

      {marks > 0 && <CustomTooltip title={<Box my={1}>
        <Typography color='primary'>The monster takes {marks} extra damage from all sources</Typography>
      </Box>}>
        <Box sx={{ position: 'absolute', top: 0, left: -35, display: 'flex', alignItems: 'center' }}>
          <Typography variant='h6'>{marks}</Typography>
          <CrisisAlertIcon color='primary' fontSize='small' />
        </Box>
      </CustomTooltip>}

      {monster.health > 0 && <CustomTooltip position={isMobile ? 'bottom' : 'right'} title={<Box my={1}>
        {monster.abilities}
      </Box>}>
        <Box sx={styles.container}>
          {MonsterComponent && <MonsterComponent monster={monster} />}
        </Box>

        {heal.View}
        {attackMinus.View}
        {attackPlus.View}
        {markEnemy.View}
      </CustomTooltip>}

    </motion.div>
  </>
}

export default Monster

const styles = {
  container: {
    position: 'relative',
    boxSizing: 'border-box',
    width: '100%',
    height: '100%',
    border: '1px solid rgba(255, 255, 255, 0.24)',
    borderRadius: '4px',
    p: 1,
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'space-between',
    overflow: 'hidden',
    transition: '0.3s',
    '&:hover': {
      border: '1px solid rgba(255, 255, 255, 0.6)',
    },
  }
}
import CrisisAlertIcon from '@mui/icons-material/CrisisAlert';
import { Box, Typography } from "@mui/material";
import { motion, useAnimationControls } from "framer-motion";
import { useLottie } from 'lottie-react';
import React, { useContext, useEffect, useRef, useState } from "react";
import { isMobile } from 'react-device-detect';
import skullAnim from "../../assets/animations/skull.json";

import markEnemyAnim from "../../assets/animations/mark_enemy.json";
import { AnimationContext } from '../../contexts/animationHandler';
import { BattleContext } from '../../contexts/battleContext';
import { CustomTooltip } from "../../helpers/styles";
import { delay } from "../../helpers/utilities";
import * as Monsters from './monsters';

function Monster(props) {
  const battle = useContext(BattleContext)
  const animationHandler = useContext(AnimationContext)

  const { monster } = props

  const [marks, setMarks] = useState(battle.state.battleEffects?.enemyMarks ?? 0)

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
    } else if (battle.state.battleEffects.enemyMarks < marks) {
      setMarks(battle.state.battleEffects.enemyMarks)
    }
  }, [battle.state.battleEffects.enemyMarks])

  useEffect(() => {
    if (monster.health <= 0) {
      fadeSkull()
      skull.play()
    }
  }, [monster.health])

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
import { useLottie } from 'lottie-react';
import React, { useContext, useEffect } from "react";
import { isMobile } from 'react-device-detect';
import rageAnim from "../../../assets/animations/rage.json";
import { AnimationContext } from '../../../contexts/animationHandler';
import MonsterMain from './main';

function Minotaur(props) {
  const animationHandler = useContext(AnimationContext)

  const { monster } = props

  useEffect(() => {
    if (animationHandler.monsterAnimations.length < 1) {
      return
    }

    const animation = animationHandler.monsterAnimations[0]

    if (animation.type === 'ability') {
      animationHandler.setMonsterAnimations(prev => prev.filter(x => x.type !== 'ability'))
      animationHandler.animationCompleted({ type: 'monsterAbility' })
    }
  }, [animationHandler.monsterAnimations])

  return <>
    <MonsterMain monster={monster} />
  </>
}

export default Minotaur
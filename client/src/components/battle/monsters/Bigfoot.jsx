import React, { useContext, useEffect } from "react";
import { AnimationContext } from '../../../contexts/animationHandler';
import MonsterMain from './main';

function Bigfoot(props) {
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

export default Bigfoot
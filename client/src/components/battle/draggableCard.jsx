import React, { useContext, useRef } from 'react'
import { isMobile, isBrowser } from 'react-device-detect'
import { motion, useAnimationControls } from 'framer-motion'
import { BattleContext } from '../../contexts/battleContext'
import { CardSize, types } from '../../helpers/cards'
import SmallCard from '../smallCard'
import { useEffect } from 'react'
import { GameContext } from '../../contexts/gameContext'

function DraggableCard(props) {
  const { values, dragEnd } = props
  const { card, clientX, clientY, rect, style } = values

  const relX = clientX - rect.left - rect.width / 2
  const relY = clientY - rect.top - rect.height / 2

  const play_threshold = isBrowser ? window.innerHeight - 200 : window.innerHeight * 0.7

  const controls = useAnimationControls()
  const ref = useRef()

  const game = useContext(GameContext)
  const battle = useContext(BattleContext)
  const playable = battle.utils.getCardCost(values.card) <= battle.state.values.heroEnergy

  useEffect(() => {
    document.addEventListener('mousemove', mouseMoveHandler);
    document.addEventListener('mouseup', mouseUpHandler);
  }, [])

  const mouseUpHandler = (event) => {
    document.removeEventListener('mousemove', mouseMoveHandler);
    document.removeEventListener('mouseup', mouseUpHandler);
    event.preventDefault();

    if (event.button !== 0 || event.pageY > play_threshold || game.values.replay || battle.state.pendingTx) {
      returnCard(event)
      return
    }

    if (values.card.category === types.CREATURE) {
      battle.actions.summonCreature(values.card)
    }

    else if (values.card.category === types.SPELL) {
      battle.actions.castSpell(values.card)
    }

    dragEnd()
  };

  const mouseMoveHandler = (event) => {
    ref.current.style.transform = `translate(${relX + event.pageX - values.pageX}px, ${relY + event.pageY - values.pageY}px)`;

    if (playable) {
      if (values.card.category === types.CREATURE) {
        if (event.pageY < play_threshold) {
          ref.current.style.border = '1px solid #FFE97F'
        } else {
          ref.current.style.border = '1px solid rgba(255, 255, 255, 0.1)'
        }
      }

      if (values.card.category === types.SPELL) {
        if (event.pageY < play_threshold) {
          ref.current.style.border = '1px solid #FFE97F'
        } else {
          ref.current.style.border = '1px solid rgba(255, 255, 255, 0.1)'
        }
      }
    }

    event.preventDefault();
  };

  const returnCard = (event) => {
    controls.start({
      x: [`${relX + event.pageX - values.pageX}px`, '0px'],
      y: [`${relY + event.pageY - values.pageY}px`, '0px'],
      rotate: [values.style.rotate, values.style.rotate]
    })
  }

  return <>
    <motion.div
      animate={controls}
      transition={{ type: 'spring', duration: 0.3 }}
      onAnimationComplete={dragEnd}
      style={isBrowser ? {
        left: style.left,
        x: clientX - rect.left - rect.width / 2,
        top: style.top,
        y: clientY - rect.top - rect.height / 2,
        ...styles.draggable
      } : {
        left: style.left,
        ...styles.mobileDraggable
      }}
      ref={ref}
    >

      <SmallCard
        key={card.id}
        card={card}
        cost={battle.utils.getCardCost(card)}
        onHand={true}
        energy={battle.state.values.heroEnergy}
        showStats={!isMobile && card.category === types.CREATURE}
      />

    </motion.div>
  </>
}

export default DraggableCard

const styles = {
  mobileDraggable: {
    userSelect: 'none',
    touchAction: 'none',
    transition: 'box-shadow 300ms cubic-bezier(0.4, 0, 0.2, 1) 0ms',
    borderRadius: '4px',
    position: 'absolute',
    zIndex: '3',
    height: CardSize.small.height,
    width: CardSize.small.width,
    cursor: 'grabbing',
    border: '1px solid yellow',
    bottom: '60px'
  },
  draggable: {
    userSelect: 'none',
    transition: 'box-shadow 300ms cubic-bezier(0.4, 0, 0.2, 1) 0ms',
    borderRadius: '4px',
    position: 'absolute',
    zIndex: '3',
    height: CardSize.medium.height,
    width: CardSize.medium.width,
    cursor: 'grabbing'
  },
  crosshair: {
    height: '60px',
    width: '60px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    position: 'fixed',
    pointerEvents: 'none',
    visibility: 'hidden'
  },
}

import { Box } from "@mui/material";
import { motion } from "framer-motion";
import React, { useContext, useState } from "react";
import { isBrowser, isMobile } from 'react-device-detect';
import { BattleContext } from "../../contexts/battleContext";
import { CardSize } from "../../helpers/cards";
import Card from "../card";
import SmallCard from "../smallCard";
import DraggableCard from "./draggableCard";
import { useReplay } from "../../contexts/replayContext";

function Hand() {
  const replay = useReplay()
  const battle = useContext(BattleContext)
  const { values, hand } = battle.state

  const [displayCard, setDisplayCard] = useState(null)
  const [selectedCard, setSelectedCard] = useState(null)

  const calculateCardPosition = (pos) => {
    const cards = hand.length

    if (cards < 5) {
      return `${(50 - cards * 12) + (pos * 24)}%`
    } else {
      return `${75 / (cards - 1) * Math.max(0.03 * cards, pos)}%`
    }
  }

  const cardStyle = (pos) => {
    const cards = hand.length

    return {
      left: calculateCardPosition(pos),
      rotate: 2 * pos - (cards - 1),
    }
  }

  const hoverCard = (card) => {
    setDisplayCard(card)
  }

  const endHoverCard = () => {
    setDisplayCard(null)
  }

  const selectCard = (event, i, card) => {
    if (selectedCard) {
      return
    }

    var rect = event.target.getBoundingClientRect()

    setSelectedCard({
      card: card,
      pos: i,
      rect: rect,
      pageX: event.pageX,
      pageY: event.pageY,
      clientX: event.clientX,
      clientY: event.clientY,
      style: cardStyle(i)
    })
  }

  const renderDisplayCard = () => {
    const cardPosition = hand.findIndex(card => card.id === displayCard?.id)

    return <motion.div
      style={{ ...(isMobile ? styles.displayCardMobile : styles.displayCard), ...styles.cardStyle, left: isMobile ? `${(window.innerWidth - 252) / 2}px` : calculateCardPosition(cardPosition) }}
      animate={{ y: '-5px' }}
      transition={{ ease: "linear", duration: 0.3 }}
    >

      <Card card={displayCard} />

    </motion.div>
  }

  const handCardStyles = (card) => {
    let style = { ...styles.cardStyle, ...(isMobile ? styles.cardMobile : styles.card), opacity: 1 }

    if ((selectedCard?.card.id === card.id) || (!selectedCard && displayCard?.id === card.id)) {
      style.opacity = 0
    }

    return style
  }

  return (
    <Box sx={styles.hand}>

      {React.Children.toArray(
        hand.map((card, i) => {
          return <>
            <motion.div
              style={{ ...(isMobile ? styles.cardWrapperMobile : styles.cardWrapper), ...cardStyle(i) }}
              onHoverStart={() => hoverCard(card)}
              onHoverEnd={() => endHoverCard()}
              onClick={event => selectCard(event, i, card)}
              onPanStart={event => { if (isBrowser) selectCard(event, i, card); }}
            />

            <motion.div
              style={handCardStyles(card)}
              animate={cardStyle(i)}
              transition={{ ease: "easeOut", duration: 0.5 }}>

              <SmallCard
                card={card}
                key={card.id}
                onHand={true}
                energy={values.heroEnergy}
                cost={battle.utils.getCardCost(card)}
                played={replay.getPlayedCards()?.includes(card.cardId)}
              />

            </motion.div>
          </>
        })
      )}

      {displayCard !== null && !selectedCard && renderDisplayCard()}

      {selectedCard && <DraggableCard
        values={selectedCard}
        dragEnd={() => setSelectedCard(null)}
      />}

    </Box >
  )
}

export default Hand

const styles = {
  hand: {
    position: 'relative',
    width: '100%',
    height: '100%',
  },
  cardWrapperMobile: {
    height: CardSize.small.height,
    width: CardSize.small.width,
    position: 'absolute',
    zIndex: 101,
    userSelect: 'none',
  },
  cardWrapper: {
    height: CardSize.medium.height,
    width: CardSize.medium.width,
    position: 'absolute',
    zIndex: 101,
    userSelect: 'none'
  },
  cardStyle: {
    position: 'absolute',
    borderRadius: '4px'
  },
  cardMobile: {
    height: CardSize.small.height,
    width: CardSize.small.width,
    left: '77%',
  },
  card: {
    height: CardSize.medium.height,
    width: CardSize.medium.width,
    left: '77%',
  },
  displayCardMobile: {
    height: CardSize.big.height,
    width: CardSize.big.width,
    bottom: '60px',
    zIndex: 100,
  },
  displayCard: {
    height: CardSize.big.height,
    width: CardSize.big.width,
    bottom: '60px',
    zIndex: 100
  },
  greenShadow: {
    boxShadow: '0px 3px 5px -2px #FFE97F, 0px 3px 5px 0px #FFE97F, 0px 1px 8px 0px #FFE97F'
  },
  drawCard: {
    position: 'fixed',
    top: '20px',
    left: '20px',
    zIndex: '2'
  },
  oppDrawCard: {
    position: 'fixed',
    top: '70px',
    left: '20px',
    zIndex: '2'
  },
  numOfCards: {
    position: 'fixed',
    top: '120px',
    left: '20px',
    width: '130px',
    zIndex: '2'
  }
};
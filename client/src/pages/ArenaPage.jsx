import React, { useContext } from 'react'
import { Scrollbars } from 'react-custom-scrollbars'
import StartDraft from '../components/landing/startDraft'
import BattleContainer from '../container/BattleContainer'
import DraftContainer from '../container/DraftContainer'
import StartBattleContainer from '../container/StartBattleContainer'
import { GameContext } from '../contexts/gameContext'

function ArenaPage() {
  const gameState = useContext(GameContext)
  const { gameId, state, replay } = gameState.values

  return (
    <Scrollbars style={{ ...styles.container, border: replay ? '1px solid #f59100' : 'none' }}>
      {gameId === null && <StartDraft />}

      {state === 'Draft' && <DraftContainer />}

      {state === 'Battle' && <BattleContainer />}

      {state === 'Map' && <StartBattleContainer />}
    </Scrollbars>
  )
}

export default ArenaPage

const styles = {
  container: {
    width: '100%',
    height: '100%',
    boxSizing: 'border-box'
  }
}
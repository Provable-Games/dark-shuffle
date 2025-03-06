import { useSnackbar } from 'notistack'
import React, { useContext, useEffect } from 'react'
import { Scrollbars } from 'react-custom-scrollbars'
import { useParams } from 'react-router-dom'
import { getTokenMetadata } from '../api/indexer'
import StartDraft from '../components/landing/startDraft'
import BattleContainer from '../container/BattleContainer'
import DraftContainer from '../container/DraftContainer'
import StartBattleContainer from '../container/StartBattleContainer'
import { GameContext } from '../contexts/gameContext'
import { useReplay } from '../contexts/replayContext'

function ArenaPage() {
  const gameState = useContext(GameContext)
  const { state } = gameState.values

  const replay = useReplay()
  const { watchGameId } = useParams()
  const { enqueueSnackbar } = useSnackbar()

  useEffect(() => {
    async function fetchGame() {
      let game = await getTokenMetadata(watchGameId)

      if (game) {
        if (game.active) {
          replay.spectateGame(game)
        } else {
          replay.startReplay(game)
        }
      } else {
        enqueueSnackbar('Game not found', { variant: 'error', anchorOrigin: { vertical: 'top', horizontal: 'center' } })
      }
    }

    if (watchGameId) {
      fetchGame()
    }
  }, [watchGameId])

  return (
    <Scrollbars style={{ ...styles.container, border: gameState.values.replay ? '1px solid #f59100' : 'none' }}>
      {gameState.values.gameId === null && <StartDraft />}

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
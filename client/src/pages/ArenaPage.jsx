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
  const { replayGameId, spectateGameId } = useParams()
  const { enqueueSnackbar } = useSnackbar()

  useEffect(() => {
    async function fetchGame() {
      let game = await getTokenMetadata(replayGameId || spectateGameId)

      if (game) {
        if (replayGameId) {
          replay.startReplay(game)
        }

        if (spectateGameId) {
          replay.spectateGame(game)
        }
      } else {
        enqueueSnackbar('Game not found', { variant: 'error', anchorOrigin: { vertical: 'top', horizontal: 'center' } })
      }
    }

    if (replayGameId || spectateGameId) {
      fetchGame()
    }
  }, [replayGameId, spectateGameId])

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
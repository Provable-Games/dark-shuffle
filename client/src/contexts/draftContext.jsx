import React, { createContext, useContext, useEffect, useState } from "react";
import { getDraft } from "../api/indexer";
import { delay } from "../helpers/utilities";
import { DojoContext } from "./dojoContext";
import { GameContext } from "./gameContext";
import { Button, IconButton } from "@mui/material";
import CloseIcon from '@mui/icons-material/Close'
import { useSnackbar } from "notistack";

export const DraftContext = createContext()

export const DraftProvider = ({ children }) => {
  const dojo = useContext(DojoContext)
  const game = useContext(GameContext)
  const { gameSettings, gameCards, tokenData } = game.getState

  const [pendingCard, setPendingCard] = useState()

  const [options, setOptions] = useState([])
  const [cards, setCards] = useState([])
  const { enqueueSnackbar, closeSnackbar } = useSnackbar()

  const startQuestGame = async () => {
    await game.actions.startBattleDirectly(tokenData.tokenId)
    game.setTokenData(prev => ({ ...prev, gameStarted: true, id: tokenData.tokenId }))
  }

  useEffect(() => {
    if (!tokenData.gameStarted && gameSettings?.starting_health && gameCards?.length > 0) {
      if (game.getState.GG_questMode) {
        startQuestGame()
      } else {
        startDraft()
      }
    }
  }, [tokenData, gameSettings, gameCards])

  const initializeDraft = () => {
    setPendingCard()
    setOptions([])
    setCards([])
  }

  const startDraft = async () => {
    initializeDraft()

    const txs = []
    txs.push({
      contractName: "game_systems",
      entrypoint: "start_game",
      calldata: [tokenData.tokenId]
    })

    game.setLoadingProgress(99)
    const res = await dojo.executeTx(txs, true)

    if (res) {
      const gameValues = res.find(e => e.componentName === 'Game')
      const draftValues = res.find(e => e.componentName === 'Draft')

      game.setGame({ ...gameValues, playerName: tokenData.playerName })
      setOptions(draftValues.options.map(option => game.utils.getCard(option)))
      setCards(draftValues.cards.map(card => game.utils.getCard(card)))

      enqueueSnackbar('Share Your Game!', {
        variant: 'info',
        anchorOrigin: { vertical: 'bottom', horizontal: 'right' },
        autoHideDuration: 15000,
        hideIconVariant: true,
        action: snackbarId => (
          <>
            <Button variant='outlined' size='small' sx={{ width: '90px', mr: 1 }}
              component='a' href={'https://x.com/intent/tweet?text=' + `I'm about to face the beasts of Dark Shuffle — come watch me play and see how far I can go! darkshuffle.io/watch/${tokenData.tokenId} 🕷️⚔️ @provablegames @darkshuffle_gg`}
              target='_blank'>
              Tweet
            </Button>
            <IconButton size='small' onClick={() => {
              closeSnackbar(snackbarId)
            }}>
              <CloseIcon color='secondary' fontSize='small' />
            </IconButton>
          </>
        )
      })
    } else if (!game.values.gameId) {
      game.utils.handleError();
    }
  }

  const selectCard = async (optionId) => {
    if (game.values.replay) {
      return
    }

    setPendingCard(optionId)

    if (game.values.isDemo) {
      await delay(500)
    }

    const res = await dojo.executeTx([{ contractName: "game_systems", entrypoint: "pick_card", calldata: [game.values.gameId, optionId] }], cards.length < gameSettings.draft_size - 1)

    if (res) {
      const gameValues = res.find(e => e.componentName === 'Game')
      const draftValues = res.find(e => e.componentName === 'Draft')

      setCards(draftValues.cards.map(card => game.utils.getCard(card)))
      setOptions(draftValues.options.map(option => game.utils.getCard(option)))

      if (gameValues) {
        game.setGame(gameValues)
      }
    }

    setPendingCard()
  }

  const fetchDraft = async (gameId) => {
    let data = await getDraft(gameId);

    setCards(data.cards.map(card => game.utils.getCard(card)));
    setOptions(data.options.map(option => game.utils.getCard(option)));
  }

  return (
    <DraftContext.Provider
      value={{
        actions: {
          selectCard,
          fetchDraft
        },

        update: {
          setOptions,
          setCards
        },

        getState: {
          cards,
          options,
          pendingCard,
        },
      }}
    >
      {children}
    </DraftContext.Provider>
  );
};
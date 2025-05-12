import { Box, Button, Typography, LinearProgress } from "@mui/material";
import { motion, useAnimationControls } from "framer-motion";
import React, { useContext, useEffect, useState } from "react";
import { isBrowser, isMobile } from 'react-device-detect';
import { BattleContext } from "../../contexts/battleContext";
import { GameContext } from "../../contexts/gameContext";

function DeathDialog(props) {
  const game = useContext(GameContext)
  const battle = useContext(BattleContext)
  const controls = useAnimationControls()

  const [text, showText] = useState(false)
  const [tweetMsg] = useState(`I fell to the darkness in Dark Shuffle after slaying ${game.values.monstersSlain} beasts, with a final score of ${game.score}. Want to see how I did it? Watch my replay here: darkshuffle.io/watch/${game.values.gameId} 🕷️⚔️ @provablegames @darkshuffle_gg`);

  useEffect(() => {
    startAnimation()
  }, [])

  const backToMenu = () => {
    battle.utils.resetBattleState()
    game.endGame()
  }

  const tryAgain = () => {
    let settingsId = game.getState.tokenData.settingsId
    battle.utils.resetBattleState()
    game.endGame()
    game.actions.mintFreeGame(settingsId)
  }

  async function startAnimation() {
    await controls.start({
      opacity: 1,
      transition: { duration: props.skipAnimation ? 1 : 3, delay: 1 }
    })

    showText(true)
  }

  const isQuestMode = game.values.questTarget;
  const isGGQuest = game.getState.GG_questMode;
  const questProgress = isQuestMode ? Math.min((game.score / game.values.questTarget) * 100, 100) : 0;

  return <motion.div style={isMobile ? styles.mobileContainer : styles.container} animate={controls}>

    {text && <Box width={'800px'} sx={{ display: 'flex', flexDirection: 'column', 'alignItems': 'center', maxWidth: '90%' }}>
      <Typography variant="h2" color={'red'}>
        A Hero Has Fallen
      </Typography>

      <Box display={'flex'} mt={6}>
        {!isQuestMode && (
          <>
            <Box mr={10}>
              <Typography variant="h4" color='primary'>
                Beasts Slain
              </Typography>

              <Typography variant="h1" mt={1} color='primary'>
                {game.values.monstersSlain}
              </Typography>
            </Box>

            <Box>
              <Typography variant="h4" color='primary'>
                Final Score
              </Typography>

              <Typography variant="h1" mt={1} color='primary'>
                {game.score}
              </Typography>
            </Box>
          </>
        )}
      </Box>

      {isQuestMode && (
        <Box mt={1} width="100%" maxWidth="600px">
          <Typography variant="h4" color='#f59100'>
            Quest {game.score < game.values.questTarget ? 'Failed' : 'Completed'}
          </Typography>
          <Box display="flex" justifyContent="space-between" alignItems="center" mb={1} mt={2}>
            <Typography variant="body1" color="primary" sx={{ opacity: 0.7 }}>
              {game.score} XP
            </Typography>
            <Typography variant="body1" color="primary" sx={{ opacity: 0.7 }}>
              {questProgress.toFixed(1)}%
            </Typography>
            <Typography variant="body1" color="primary" sx={{ opacity: 0.7 }}>
              {game.values.questTarget} XP
            </Typography>
          </Box>
          <LinearProgress
            variant="determinate"
            value={questProgress}
            sx={{
              height: 10,
              borderRadius: 5,
              backgroundColor: 'rgba(255, 255, 255, 0.1)',
              '& .MuiLinearProgress-bar': {
                background: 'linear-gradient(90deg, #FFD700 0%, #FFA500 100%)',
                borderRadius: 5,
              }
            }}
          />
        </Box>
      )}

      {isBrowser && !isQuestMode && <>
        <Typography mt={6}>
          Your journey ends here, brave hero, swallowed by the unforgiving darkness of the mist.
          In this silent tomb, your valor and strife are sealed away, a whisper lost among the echoes of countless others who dared to challenge the abyss.
        </Typography>

        <Typography mt={4}>
          This place remains, eternal and unyielding, its secrets forever guarded by shadows.
        </Typography>
      </>}

      {!isGGQuest && isBrowser && isQuestMode && <>
        <Typography mt={6}>
          {game.score < game.values.questTarget ? 'Better luck next time, brave hero.' : 'Return to Eternum to claim your reward.'} <br />
          The darkness has claimed you this time, but your adventure in Eternum continues.
        </Typography>
      </>}

      {isGGQuest && isBrowser && isQuestMode && <>
        <Typography mt={6}>
          {game.score < game.values.questTarget ? 'Better luck next time, brave hero.' : ''} <br />
          The darkness has claimed you this time, but your adventure continues.
        </Typography>
      </>}

      {!isGGQuest && <Box mt={6} display={'flex'} gap={3}>
        {!isQuestMode && (
          <Button color='secondary' variant='outlined' size='large' sx={{ fontSize: '16px', letterSpacing: '1px' }}
            component='a' href={'https://x.com/intent/tweet?text=' + tweetMsg} target='_blank'>
            Share on X
          </Button>
        )}

        <Button variant='outlined' size='large' sx={{ fontSize: isQuestMode ? '14px' : '16px', letterSpacing: '1px' }} onClick={isQuestMode ? () => window.close() : backToMenu}>
          {isQuestMode ? "Done" : "Play again"}
        </Button>
      </Box>}

      {isGGQuest && <Box mt={6} display={'flex'} gap={3}>
        <Button color='secondary' variant='outlined' size='large' sx={{ fontSize: '16px', letterSpacing: '1px' }} onClick={backToMenu}>
          Back to Quests
        </Button>

        <Button variant='outlined' size='large' sx={{ fontSize: '16px', letterSpacing: '1px' }} onClick={tryAgain}>
          Try Again
        </Button>
      </Box>}
    </Box>}

  </motion.div>
}

export default DeathDialog

const styles = {
  container: {
    position: 'absolute',
    top: 0,
    opacity: 0,
    background: 'rgb(0, 0, 0)',
    zIndex: 999,
    boxSizing: 'border-box',
    width: '100%',
    height: 'calc(100% - 42px)',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    textAlign: 'center'
  },
  mobileContainer: {
    position: 'absolute',
    top: 0,
    opacity: 0,
    background: 'rgb(0, 0, 0)',
    zIndex: 99,
    boxSizing: 'border-box',
    width: '100%',
    height: '100%',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    textAlign: 'center'
  }
}
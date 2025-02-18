import { Box, Button, Typography } from "@mui/material";
import React, { useContext, useEffect, useState } from "react";
import { GameContext } from "../../contexts/gameContext";
import { BattleContext } from "../../contexts/battleContext";
import { motion, useAnimationControls } from "framer-motion";
import { isMobile, isBrowser } from 'react-device-detect'

function DeathDialog(props) {
  const game = useContext(GameContext)
  const battle = useContext(BattleContext)
  const controls = useAnimationControls()

  const [text, showText] = useState(false)
  const [tweetMsg] = useState(`I fell to the darkness in Dark Shuffle after slaying ${game.values.monstersSlain} beasts, with a final score of ${game.score}. Can you outlast me? Play now at darkshuffle.io 🕷️⚔️ @provablegames #DarkShuffle`);

  useEffect(() => {
    startAnimation()
  }, [])

  const backToMenu = () => {
    battle.utils.resetBattleState()
    game.endGame()
  }

  async function startAnimation() {
    await controls.start({
      opacity: 1,
      transition: { duration: 3, delay: 1 }
    })

    showText(true)
  }

  return <motion.div style={isMobile ? styles.mobileContainer : styles.container} animate={controls}>

    {text && <Box width={'800px'} sx={{ display: 'flex', flexDirection: 'column', 'alignItems': 'center', maxWidth: '90%' }}>
      <Typography variant="h2" color={'red'}>
        A Hero Has Fallen
      </Typography>

      <Box display={'flex'} mt={6}>
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
      </Box>

      {isBrowser && <>
        <Typography mt={6}>
          Your journey ends here, brave hero, swallowed by the unforgiving darkness of the mist.
          In this silent tomb, your valor and strife are sealed away, a whisper lost among the echoes of countless others who dared to challenge the abyss.
        </Typography>

        <Typography mt={4}>
          This place remains, eternal and unyielding, its secrets forever guarded by shadows.
        </Typography>
      </>}

      <Box mt={6} display={'flex'} gap={3}>
        <Button color='secondary' variant='outlined' size='large' sx={{ fontSize: '16px', letterSpacing: '1px' }}
          component='a' href={'https://x.com/intent/tweet?text=' + tweetMsg} target='_blank'>
          Share on X
        </Button>

        <Button variant='outlined' size='large' sx={{ fontSize: '16px', letterSpacing: '1px' }} onClick={backToMenu}>
          Play again
        </Button>
      </Box>
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
    height: 'calc(100% - 55px)',
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
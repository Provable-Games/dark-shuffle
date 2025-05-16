import React, { useContext, useState, useEffect } from 'react';
import { Box, Button, Typography, Container } from '@mui/material';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import questImage from "../../assets/images/eternum_quest.png";
import { GameContext } from '../../contexts/gameContext';

const containerVariant = {
  hidden: {
    opacity: 0
  },
  visible: {
    opacity: 1,
    transition: {
      duration: 0.6,
      staggerChildren: 0.15
    }
  }
};

const elementVariant = {
  hidden: {
    opacity: 0,
    y: 10
  },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.5,
      ease: [0.23, 1, 0.32, 1] // Custom easing for smooth entrance
    }
  }
};

const getQuestName = (settingsId) => {
  switch (settingsId) {
    case 3:
      return 'Newbie';
    case 6:
      return 'Easy';
    case 4:
      return 'Medium';
    case 1:
      return 'Hard';
    case 5:
      return 'Nightmare';
    default:
      return '';
  }
}

const QuestComplete = () => {
  const navigate = useNavigate();
  const game = useContext(GameContext);
  const [tweetMsg] = useState(`I just earned resources in @RealmsEternum by completing a @darkshuffle_gg ${getQuestName(game.getState.tokenData.settingsId)} Quest! 🎮\n\nWant to experience the power of open & composable gaming?\n\nJoin Eternum S1 today and see for yourself why players and builders are choosing onchain!`);

  const isGGQuest = game.getState.GG_questMode;

  useEffect(() => {
    const completedQuests = JSON.parse(localStorage.getItem('completedQuests') || '[]');
    const currentSettingsId = game.getState.tokenData.settingsId;

    if (!completedQuests.includes(currentSettingsId)) {
      completedQuests.push(currentSettingsId);
      localStorage.setItem('completedQuests', JSON.stringify(completedQuests));
    }
  }, [game.getState.tokenData.settingsId]);

  const backToMenu = () => {
    navigate('/');
    game.endGame();
  };



  return (
    <Container maxWidth="lg" sx={styles.container}>
      <motion.div
        variants={containerVariant}
        initial="hidden"
        animate="visible"
        style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}
      >
        {/* Quest icon */}
        <motion.div
          variants={elementVariant}
          style={{ marginBottom: '40px', zIndex: 2 }}
        >
          <Box sx={styles.questIconContainer}>
            <motion.div
              animate={{
                y: [0, -5, 0],
              }}
              transition={{
                duration: 3,
                repeat: Infinity,
                repeatType: "reverse"
              }}
            >
              <Box sx={styles.questIconWrapper}>
                <img
                  src={questImage}
                  alt="Quest Complete"
                  style={styles.questIcon}
                />
              </Box>
            </motion.div>
          </Box>
        </motion.div>

        {/* Quest completed text */}
        <motion.div variants={elementVariant}>
          <Box sx={styles.titleContainer}>
            <Typography variant="h2" sx={styles.title}>
              QUEST COMPLETED
            </Typography>
            <Box sx={styles.titleUnderline} />
          </Box>
        </motion.div>

        {/* Reward message */}
        <motion.div variants={elementVariant}>
          <Box sx={styles.subtitleContainer}>
            <Typography variant="h5" sx={styles.subtitle}>
              {isGGQuest ? 'Your legend grows stronger' : 'Return to Eternum to claim your reward'}
            </Typography>
          </Box>
        </motion.div>

        {/* Buttons */}
        {!isGGQuest && <motion.div variants={elementVariant} style={{ marginTop: '40px', display: 'flex', gap: '20px', zIndex: 2 }}>
          <Button
            color='warning'
            variant='outlined'
            size='large'
            sx={styles.shareButton}
            component='a'
            href={'https://x.com/intent/tweet?text=' + encodeURIComponent(tweetMsg)}
            target='_blank'
          >
            Share on X
          </Button>

          <Button
            variant="outlined"
            color="primary"
            size="large"
            onClick={() => window.close()}
            sx={{ fontSize: '14px', minWidth: '135px' }}
          >
            Done
          </Button>
        </motion.div>}

        {isGGQuest && <motion.div variants={elementVariant} style={{ marginTop: '40px', display: 'flex', gap: '20px', zIndex: 2 }}>
          <Button
            variant="outlined"
            color="primary"
            size="large"
            onClick={backToMenu}
            sx={{ fontSize: '14px', minWidth: '135px' }}
          >
            Back to Quests
          </Button>
        </motion.div>}
      </motion.div>
    </Container>
  );
};

const styles = {
  container: {
    height: '100%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
    overflow: 'hidden',
  },
  questIconContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: '20px',
    position: 'relative',
  },
  questIconWrapper: {
    position: 'relative',
    width: '200px',
    height: '200px',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
  },
  questIcon: {
    width: '100%',
    height: '100%',
    objectFit: 'contain',
    position: 'relative',
    zIndex: 2,
  },
  titleContainer: {
    position: 'relative',
    marginBottom: '20px',
    padding: '0 20px',
  },
  title: {
    color: '#f59100',
    fontWeight: 'bold',
    textShadow: '0 0 10px rgba(255, 233, 127, 0.1)',
    textAlign: 'center',
    letterSpacing: '4px',
    position: 'relative',
    zIndex: 1,
    marginBottom: '20px',
  },
  titleUnderline: {
    position: 'absolute',
    bottom: '-15px',
    left: '50%',
    transform: 'translateX(-50%)',
    width: '80%',
    height: '2px',
    background: 'linear-gradient(90deg, transparent, rgba(245, 145, 0, 0.5), transparent)',
  },
  subtitleContainer: {
    position: 'relative',
    marginBottom: '40px',
    padding: '20px',
  },
  subtitle: {
    color: 'white',
    textAlign: 'center',
    letterSpacing: '2px',
    zIndex: 1,
  },
  shareButton: {
    letterSpacing: '1px',
    fontSize: '14px',
  },
};

export default QuestComplete;

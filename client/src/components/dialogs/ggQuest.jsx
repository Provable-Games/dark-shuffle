import StarIcon from '@mui/icons-material/Star';
import StarBorderIcon from '@mui/icons-material/StarBorder';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import { Box, Button, Dialog, Typography } from '@mui/material';
import { motion } from "framer-motion";
import { useContext, useState, useEffect } from "react";
import { isMobile } from 'react-device-detect';
import { GameContext } from '../../contexts/gameContext';
import { fadeVariant } from "../../helpers/variants";

// Import quest images
import hardImage from '../../assets/images/cards/dragon.png';
import easyImage from '../../assets/images/cards/fairy.png';
import newbieImage from '../../assets/images/cards/pixie.png';
import nightmareImage from '../../assets/images/cards/tarrasque.png';
import mediumImage from '../../assets/images/cards/werewolf.png';
import { useAccount, useConnect } from '@starknet-react/core';
import { useNavigate } from 'react-router-dom';

const QUEST_LEVELS = [
  {
    name: 'Newbie',
    difficulty: 1,
    settingsId: 3,
    targetScore: 26,
    color: '#4CAF50',
    image: newbieImage,
  },
  {
    name: 'Easy',
    difficulty: 2,
    settingsId: 6,
    targetScore: 26,
    color: '#8BC34A',
    image: easyImage,
  },
  {
    name: 'Medium',
    difficulty: 3,
    settingsId: 4,
    targetScore: 26,
    color: '#FFC107',
    image: mediumImage,
  },
  {
    name: 'Hard',
    difficulty: 4,
    settingsId: 1,
    targetScore: 51,
    color: '#FF9800',
    image: hardImage,
  },
  {
    name: 'Nightmare',
    difficulty: 5,
    settingsId: 5,
    targetScore: 101,
    color: '#F44336',
    image: nightmareImage,
  }
];

function GGQuest(props) {
  const { open } = props;

  const { account } = useAccount()
  const { connect, connectors } = useConnect()
  const navigate = useNavigate()

  const gameContext = useContext(GameContext);
  const [selectedQuest, setSelectedQuest] = useState(null);
  const [questLevels, setQuestLevels] = useState(QUEST_LEVELS);

  useEffect(() => {
    // Get completed quests from localStorage
    const completedQuests = JSON.parse(localStorage.getItem('completedQuests') || '[]');
    
    // Update quest levels with completion status
    const updatedQuestLevels = QUEST_LEVELS.map(quest => ({
      ...quest,
      isCompleted: completedQuests.includes(quest.settingsId)
    }));
    
    setQuestLevels(updatedQuestLevels);
  }, []);

  const startQuest = async (quest) => {
    if (!account) {
      connect({ connector: connectors.find(conn => conn.id === "controller") })
      return
    }

    gameContext.utils.setQuestTargetScore(quest.targetScore)
    gameContext.actions.mintFreeGame(quest.settingsId)
  };

  const exitQuestMode = () => {
    gameContext.utils.setQuestMode(false)
    gameContext.utils.setQuestTargetScore(0)
    navigate('/')
  }

  const renderDifficultyStars = (difficulty) => {
    return Array(5).fill(0).map((_, index) => {
      if (index < difficulty) {
        return <StarIcon key={index} sx={{ color: '#FFE97F' }} />;
      }
      return <StarBorderIcon key={index} sx={{ color: '#FFE97F50' }} />;
    });
  };

  return (
    <Dialog
      open={open}
      maxWidth={'lg'}
      PaperProps={{
        sx: {
          background: 'rgba(0, 0, 0, 1)',
          border: '2px solid #FFE97F',
          maxWidth: '98vw',
          borderRadius: '8px'
        }
      }}
    >
      <Box sx={isMobile ? styles.mobileContainer : styles.container}>
        <motion.div variants={fadeVariant} exit='exit' animate='enter'>
          <Typography variant='h4' color='primary' sx={styles.title}>
            Choose Your Quest
          </Typography>

          <Box sx={styles.questGrid}>
            {questLevels.map((quest) => (
              <Box
                key={quest.name}
                sx={{
                  ...styles.questCard,
                  borderColor: selectedQuest?.name === quest.name ? quest.color : '#FFE97F50',
                  '&:hover': {
                    borderColor: quest.color,
                    transform: 'translateY(-2px)',
                    '& img': {
                      opacity: 1,
                      transform: 'scale(1.05)',
                    }
                  }
                }}
                onClick={() => setSelectedQuest(quest)}
              >
                {quest.isCompleted && (
                  <CheckCircleIcon 
                    sx={{
                      position: 'absolute',
                      top: '8px',
                      right: '8px',
                      color: '#4CAF50',
                      fontSize: '26px',
                      zIndex: 1
                    }}
                  />
                )}
                <Box
                  component="img"
                  src={quest.image}
                  alt={quest.name}
                  sx={{
                    ...styles.questImage,
                    opacity: quest.isCompleted ? 0.6 : 0.8,
                  }}
                />
                <Typography variant='h5' color='primary' sx={{ color: quest.color }}>
                  {quest.name}
                </Typography>
                <Box sx={styles.starsContainer}>
                  {renderDifficultyStars(quest.difficulty)}
                </Box>
              </Box>
            ))}
          </Box>

          <Box sx={styles.buttonContainer}>
            <Button
              variant='contained'
              disabled={!selectedQuest}
              onClick={() => selectedQuest && startQuest(selectedQuest)}
              sx={{
                ...styles.button,
                background: selectedQuest ? selectedQuest.color : '#FFE97F50',
                '&:hover': {
                  background: selectedQuest ? `${selectedQuest.color}CC` : '#FFE97F50',
                }
              }}
            >
              <Typography color='black'>
                {selectedQuest ? `Start ${selectedQuest.name} Quest` : 'Select a Quest'}
              </Typography>
            </Button>
          </Box>
          <Typography
            onClick={exitQuestMode}
            sx={styles.exitLink}
          >
            Exit Quests
          </Typography>
        </motion.div>
      </Box>
    </Dialog>
  );
}

export default GGQuest;

const styles = {
  container: {
    display: 'flex',
    flexDirection: 'column',
    padding: '30px',
    pb: '10px',
    width: '800px',
  },
  mobileContainer: {
    display: 'flex',
    flexDirection: 'column',
    padding: '16px',
    width: '100%',
    maxWidth: '500px',
    minHeight: '600px',
    boxSizing: 'border-box',
  },
  title: {
    textAlign: 'center',
    marginBottom: '20px',
    fontWeight: 'bold',
  },
  questGrid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
    gap: '16px',
    marginBottom: '20px',
  },
  questCard: {
    background: 'rgba(255, 233, 127, 0.05)',
    border: '2px solid',
    borderRadius: '8px',
    padding: '20px',
    cursor: 'pointer',
    transition: 'all 0.3s ease',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: '12px',
    position: 'relative',
    overflow: 'hidden',
  },
  questImage: {
    width: '100%',
    height: '110px',
    maxHeight: '13vh',
    objectFit: 'contain',
    opacity: 0.8,
    transition: 'all 0.3s ease',
  },
  starsContainer: {
    display: 'flex',
    gap: '4px',
  },
  description: {
    fontSize: '14px',
    opacity: 0.8,
  },
  buttonContainer: {
    display: 'flex',
    justifyContent: 'center',
    gap: '16px',
    marginTop: 'auto',
    pb: 2
  },
  button: {
    minWidth: '160px',
    height: '48px',
  },
  exitLink: {
    position: 'absolute',
    bottom: '8px',
    right: '16px',
    color: '#FFE97F80',
    fontSize: '0.875rem',
    cursor: 'pointer',
    '&:hover': {
      color: '#FFE97F',
    },
  },
};

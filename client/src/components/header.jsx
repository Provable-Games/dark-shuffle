import CloseIcon from '@mui/icons-material/Close';
import InfoIcon from '@mui/icons-material/Info';
import SettingsIcon from '@mui/icons-material/Settings';
import SportsEsportsIcon from '@mui/icons-material/SportsEsports';
import { LoadingButton } from '@mui/lab';
import { Box, Button, IconButton, LinearProgress, Typography } from '@mui/material';
import { useConnect } from "@starknet-react/core";
import React, { useContext, useEffect, useState } from 'react';
import { Link, useNavigate } from "react-router-dom";
import logo from '../assets/images/logo.svg';
import { BattleContext } from '../contexts/battleContext';
import { DojoContext } from '../contexts/dojoContext';
import { GameContext } from '../contexts/gameContext';
import { ellipseAddress } from '../helpers/utilities';
import ChooseName from './dialogs/chooseName';
import GameSettings from './dialogs/gameSettings';
import GameSettingsList from './dialogs/gameSettingsList';
import ProfileMenu from './header/profileMenu';
import { useParams } from 'react-router-dom';

const menuItems = [
  {
    name: 'Play',
    path: '/',
    icon: <InfoIcon />
  },
]

function Header(props) {
  const game = useContext(GameContext)
  const battle = useContext(BattleContext)
  const navigate = useNavigate()
  const { watchGameId, gameId } = useParams()

  const { connect, connector, connectors } = useConnect();
  let cartridgeConnector = connectors.find(conn => conn.id === "controller")

  const dojo = useContext(DojoContext)

  const [nameDialog, openNameDialog] = useState(false)
  const [gameSettings, openGameSettings] = useState(false)

  const [anchorEl, setAnchorEl] = useState(null);

  const [questProgress, setQuestProgress] = useState(0);
  const questTarget = 300;
  const questCurrent = 150;

  useEffect(() => {
    const timer = setTimeout(() => {
      setQuestProgress((questCurrent / questTarget) * 100);
    }, 100);
    return () => clearTimeout(timer);
  }, [questCurrent, questTarget]);

  const handleClick = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  const backToMenu = () => {
    navigate('/')
    battle.utils.resetBattleState()
    game.endGame()
  }

  if (game.getState.loading || ((watchGameId || gameId) && !game.values.gameId)) {
    return null
  }

  const inGame = game.values.gameId && !game.values.replay
  let quest = false

  return (
    <Box sx={[styles.header, { height: inGame ? '42px' : '55px', pl: inGame ? 1 : 3 }]}>

      <Box sx={{ display: 'flex', alignItems: 'center', gap: 3 }}>
        <Box sx={{ height: '32px', opacity: 1, cursor: 'pointer', display: 'flex', alignItems: 'center' }} onClick={backToMenu}>
          {inGame ? <CloseIcon fontSize='medium' htmlColor='white' /> : <img alt='' src={logo} height='32' />}
        </Box>

        {!inGame && menuItems.map(item => {
          return <Link to={item.path} key={item.name} sx={styles.item}>
            <Box sx={styles.content}>
              <Typography>
                {item.name}
              </Typography>
            </Box>
          </Link>
        })}
      </Box>

      {quest && (
        <Box sx={styles.questContainer}>
          <Box sx={styles.questContent}>
            <Typography variant="caption" sx={styles.questLabel}>
              QUEST PROGRESS
            </Typography>
            <Box sx={styles.progressContainer}>
              <LinearProgress
                variant="determinate"
                value={questProgress}
                sx={styles.progressBar}
              />
              <Typography variant="caption" sx={styles.questText}>
                {questCurrent}/{questTarget} XP
              </Typography>
            </Box>
          </Box>
        </Box>
      )}

      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        {dojo.address
          ? <Button onClick={() => connector.controller.openProfile()} startIcon={<SportsEsportsIcon />} size={inGame ? 'small' : 'medium'} variant='outlined'>
            {dojo.userName
              ? <Typography color='primary' sx={{ fontSize: '12px' }}>
                {dojo.userName.toUpperCase()}
              </Typography>
              : <Typography color='primary' sx={{ fontSize: '12px' }}>
                {ellipseAddress(dojo.address, 4, 4)}
              </Typography>}
          </Button>

          : <LoadingButton loading={dojo.connecting} variant='outlined' onClick={() => connect({ connector: cartridgeConnector })} size='medium' startIcon={<SportsEsportsIcon />}>
            <Typography color='primary'>
              Connect
            </Typography>
          </LoadingButton>
        }

        <IconButton onClick={handleClick} size={inGame ? 'small' : 'medium'}>
          <SettingsIcon color='primary' />
        </IconButton>
      </Box>

      <ProfileMenu handleClose={handleClose} anchorEl={anchorEl} openNameDialog={openNameDialog} openGameSettings={openGameSettings} inGame={inGame} backToMenu={backToMenu} />
      <ChooseName open={nameDialog} close={openNameDialog} />

      {(gameSettings && !inGame) && <GameSettingsList open={gameSettings} close={openGameSettings} />}
      {(gameSettings && inGame) && <GameSettings settingsId={game.getState.tokenData.settingsId} view={true} close={() => openGameSettings(false)} />}
    </Box>
  );
}

export default Header

const styles = {
  header: {
    width: '100%',
    borderBottom: '1px solid rgba(255, 255, 255, 0.12)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    pr: 1,
    boxSizing: 'border-box',
    gap: 4
  },
  item: {
    letterSpacing: '1px',
  },
  logo: {
    cursor: 'pointer',
    height: '100%',
  },
  content: {
    textDecoration: 'none',
    color: 'white',
  },
  menu: {
    width: 300
  },
  questContainer: {
    display: 'flex',
    alignItems: 'center',
    background: 'rgba(0, 0, 0, 0.2)',
    borderRadius: '12px',
    padding: '4px 12px',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    transition: 'all 0.3s ease',
  },
  questContent: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: '2px',
  },
  questLabel: {
    color: '#FFD700',
    fontWeight: 'bold',
    letterSpacing: '1px',
    fontSize: '10px',
  },
  progressContainer: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    minWidth: '150px',
  },
  progressBar: {
    flex: 1,
    height: '6px',
    borderRadius: '3px',
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    '& .MuiLinearProgress-bar': {
      background: 'linear-gradient(90deg, #FFD700 0%, #FFA500 100%)',
      borderRadius: '3px',
      transition: 'transform 0.5s ease-in-out',
    }
  },
  questText: {
    color: 'white',
    fontWeight: 'bold',
    fontSize: '12px',
    minWidth: '60px',
    textAlign: 'right',
  }
};
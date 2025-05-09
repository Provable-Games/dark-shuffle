import CloseIcon from '@mui/icons-material/Close';
import InfoIcon from '@mui/icons-material/Info';
import SettingsIcon from '@mui/icons-material/Settings';
import SportsEsportsIcon from '@mui/icons-material/SportsEsports';
import { LoadingButton } from '@mui/lab';
import { Box, Button, IconButton, Typography } from '@mui/material';
import { useConnect } from "@starknet-react/core";
import React, { useContext, useState } from 'react';
import { Link, useNavigate, useParams } from "react-router-dom";
import logo from '../assets/images/logo.svg';
import { BattleContext } from '../contexts/battleContext';
import { DojoContext } from '../contexts/dojoContext';
import { GameContext } from '../contexts/gameContext';
import { ellipseAddress } from '../helpers/utilities';
import ChooseName from './dialogs/chooseName';
import GameSettings from './dialogs/gameSettings';
import GameSettingsList from './dialogs/gameSettingsList';
import ProfileMenu from './header/profileMenu';
import { CustomTooltip } from '../helpers/styles';

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
  const { showSettingsId } = useParams()

  const { connect, connector, connectors } = useConnect();
  let cartridgeConnector = connectors.find(conn => conn.id === "controller")

  const dojo = useContext(DojoContext)

  const [nameDialog, openNameDialog] = useState(false)
  const [gameSettings, openGameSettings] = useState(Boolean(showSettingsId))

  const [anchorEl, setAnchorEl] = useState(null);

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

  if (game.getState.loading) {
    return null
  }

  const inGame = game.values.gameId && !game.values.replay

  return (
    <Box sx={[styles.header, { height: inGame ? '42px' : '55px', pl: inGame ? 1 : 3 }]}>

      <Box sx={{ display: 'flex', alignItems: 'center', gap: 3 }}>
        <CustomTooltip title="Exit Game" position='right'>
          <Box sx={{ height: '32px', opacity: 1, cursor: 'pointer', display: 'flex', alignItems: 'center' }} onClick={backToMenu}>
            {inGame ? <CloseIcon fontSize='medium' htmlColor='white' /> : <img alt='' src={logo} height='32' />}
          </Box>
        </CustomTooltip>

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

      {(gameSettings && !inGame) && <GameSettingsList open={gameSettings} close={() => openGameSettings(false)} />}
      {(gameSettings && inGame) && <GameSettings inGame={inGame} settingsId={game.getState.tokenData.settingsId} view={true} close={() => openGameSettings(false)} />}
      {(showSettingsId && gameSettings) && <GameSettings settingsId={showSettingsId} view={true} close={() => { openGameSettings(false); navigate(`/`) }} />}
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
};
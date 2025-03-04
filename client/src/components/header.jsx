import InfoIcon from '@mui/icons-material/Info';
import SettingsIcon from '@mui/icons-material/Settings';
import SportsEsportsIcon from '@mui/icons-material/SportsEsports';
import { LoadingButton } from '@mui/lab';
import { Box, Button, IconButton, Typography } from '@mui/material';
import { useConnect } from "@starknet-react/core";
import React, { useContext, useState } from 'react';
import { Link, useNavigate } from "react-router-dom";
import logo from '../assets/images/logo.svg';
import { BattleContext } from '../contexts/battleContext';
import { DojoContext } from '../contexts/dojoContext';
import { GameContext } from '../contexts/gameContext';
import { ellipseAddress } from '../helpers/utilities';
import ChooseName from './dialogs/chooseName';
import ConnectWallet from './dialogs/connectWallet';
import TutorialDialog from './dialogs/tutorial';
import ProfileMenu from './header/profileMenu';

const menuItems = [
  {
    name: 'Play Season',
    path: '/',
    icon: <InfoIcon />
  },
]

function Header(props) {
  const game = useContext(GameContext)
  const battle = useContext(BattleContext)
  const navigate = useNavigate()

  const { connect, connector, connectors } = useConnect();
  let cartridgeConnector = connectors.find(conn => conn.id === "controller")

  const dojo = useContext(DojoContext)

  const [connectWallet, openConnectWallet] = useState(false)
  const [tutorial, openTutorial] = useState(false)
  const [nameDialog, openNameDialog] = useState(false)

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

  return (
    <Box sx={styles.header}>

      <Box sx={{ display: 'flex', alignItems: 'center', gap: 3 }}>
        <Box height={32} sx={{ opacity: 1, cursor: 'pointer' }} onClick={backToMenu}>
          <img alt='' src={logo} height='32' />
        </Box>

        {menuItems.map(item => {
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
          ? <Button onClick={() => connector.controller.openProfile()} startIcon={<SportsEsportsIcon />} size='medium' variant='outlined'>
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

        <IconButton onClick={handleClick} size='medium'>
          <SettingsIcon color='primary' />
        </IconButton>
      </Box>

      <ProfileMenu handleClose={handleClose} anchorEl={anchorEl} openNameDialog={openNameDialog} />
      <ChooseName open={nameDialog} close={openNameDialog} />
      <TutorialDialog open={tutorial} close={openTutorial} />
      <ConnectWallet open={connectWallet} close={openConnectWallet} />
    </Box>
  );
}

export default Header

const styles = {
  header: {
    width: '100%',
    height: '55px',
    borderBottom: '1px solid rgba(255, 255, 255, 0.12)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    pr: 1,
    pl: 3,
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
  }
};
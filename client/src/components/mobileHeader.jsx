import DeleteForeverIcon from '@mui/icons-material/DeleteForever';
import InfoIcon from '@mui/icons-material/Info';
import LogoutIcon from '@mui/icons-material/Logout';
import MenuIcon from '@mui/icons-material/Menu';
import SportsEsportsIcon from '@mui/icons-material/SportsEsports';
import { LoadingButton } from '@mui/lab';
import { Box, Divider, IconButton, List, Typography } from '@mui/material';
import SwipeableDrawer from '@mui/material/SwipeableDrawer';
import { useConnect, useDisconnect } from '@starknet-react/core';
import React, { useContext, useState } from 'react';
import { Link } from 'react-router-dom';
import { DojoContext } from '../contexts/dojoContext';
import { GameContext } from '../contexts/gameContext';
import { formatNumber } from '../helpers/utilities';

const menuItems = [
  {
    name: 'Play Season',
    path: '/',
    icon: <InfoIcon />
  },
]

function MobileHeader(props) {
  const dojo = useContext(DojoContext)
  const game = useContext(GameContext)

  const { connect, connector, connectors } = useConnect();
  const { disconnect } = useDisconnect()
  let cartridgeConnector = connectors.find(conn => conn.id === "controller")

  const [menu, toggleMenu] = useState(false)

  const abandonGame = async () => {
    if (game.values.replay) {
      return
    }

    await dojo.executeTx([{
      contractName: "game_systems",
      entrypoint: "abandon_game",
      calldata: [game.values.gameId]
    }])

    window.location.reload();
  }

  return <Box sx={styles.mobileHeader}>
    <Box />

    <Box>
      <IconButton onClick={() => toggleMenu(true)} size='large' sx={{ mt: 1 }}>
        <MenuIcon sx={{ fontSize: '30px' }} />
      </IconButton>

      <SwipeableDrawer
        anchor={'top'}
        open={menu}
        onClose={() => toggleMenu(false)}
        onOpen={() => toggleMenu(true)}
      >

        <List>
          {menuItems.map(item => {
            return <Link to={item.path} key={item.name} sx={styles.item}>
              <Box sx={styles.content}>
                <Typography variant='h6'>
                  {item.name}
                </Typography>
              </Box>
            </Link>
          })}
        </List>

        <Divider />

        {!dojo.address && <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, p: 2 }}>
          <LoadingButton fullWidth loading={dojo.connecting} variant='outlined' onClick={() => connect({ connector: cartridgeConnector })} size='large' startIcon={<SportsEsportsIcon />}>
            <Typography color='primary'>
              Connect
            </Typography>
          </LoadingButton>
        </Box>
        }

        {dojo.address && <>
          <Box px={2} display={'flex'} justifyContent={'space-between'} alignItems={'center'} mt={2} onClick={() => connector.controller.openProfile()}>
            <Box display={'flex'} alignItems={'center'} gap={1}>
              <SportsEsportsIcon fontSize="small" color='primary' />

              <Typography color='primary' sx={{ fontSize: '13px' }}>
                {dojo.userName?.toUpperCase()}
              </Typography>
            </Box>

            <Box display={'flex'} gap={0.5} alignItems={'center'}>
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="#FFE97F" height={12}><path d="M0 12v2h1v2h6V4h2v12h6v-2h1v-2h-2v2h-3V4h2V0h-2v2H9V0H7v2H5V0H3v4h2v10H2v-2z"></path></svg>
              <Typography color={'primary'} sx={{ fontSize: '13px' }}>
                {formatNumber(parseInt(dojo.balances.lords.toString()) / 10 ** 18)}
              </Typography>
            </Box>
          </Box>

          <Divider sx={{ my: 2 }} />

          {game.values.gameId && <>
            <Box display={'flex'} alignItems={'center'} justifyContent={'space-between'} boxSizing={'borderBox'} px={2} onClick={abandonGame}>
              <Box display={'flex'} alignItems={'center'} gap={1}>
                <DeleteForeverIcon fontSize="small" htmlColor='#fb3a3a' />

                <Typography sx={{ fontSize: '13px', color: '#fb3a3a' }}>
                  ABANDON GAME
                </Typography>
              </Box>
            </Box>

            <Divider sx={{ my: 2 }} />
          </>}

          <Box display={'flex'} alignItems={'center'} justifyContent={'space-between'} boxSizing={'borderBox'} px={2} onClick={disconnect}>
            <Box display={'flex'} alignItems={'center'} gap={1}>
              <LogoutIcon fontSize="small" />

              <Typography sx={{ fontSize: '13px' }}>
                DISCONNECT
              </Typography>
            </Box>
          </Box>

          <Divider sx={{ mt: 2 }} />
        </>}

      </SwipeableDrawer>
    </Box>
  </Box>
}

export default MobileHeader

const styles = {
  mobileHeader: {
    position: 'fixed',
    top: 0,
    width: '100%',
    margin: 'auto',
    height: '40px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    pl: 2,
    boxSizing: 'border-box',
    gap: 4,
    zIndex: 999
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
    display: 'flex',
    alignItems: 'center',
    gap: 2,
    height: '40px',
    px: 2,
    boxSizing: 'border-box',
    textAlign: 'center',
    justifyContent: 'center',
  },
};
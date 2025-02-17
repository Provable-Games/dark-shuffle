import EditIcon from '@mui/icons-material/Edit';
import EmojiEventsIcon from '@mui/icons-material/EmojiEvents';
import GitHubIcon from '@mui/icons-material/GitHub';
import LogoutIcon from '@mui/icons-material/Logout';
import PersonIcon from '@mui/icons-material/Person';
import SportsScoreIcon from '@mui/icons-material/SportsScore';
import XIcon from '@mui/icons-material/X';
import { Box, Divider, IconButton, ListItemIcon, ListItemText, Menu, MenuItem, Typography } from '@mui/material';
import { useDisconnect } from '@starknet-react/core';
import React, { useContext } from 'react';
import { DojoContext } from '../../contexts/dojoContext';
import { useTournament } from '../../contexts/tournamentContext';
import { formatNumber } from '../../helpers/utilities';
import { dojoConfig } from '../../../dojo.config';

function ProfileMenu(props) {
  const { handleClose, anchorEl, openNameDialog } = props
  const { disconnect } = useDisconnect()

  const dojo = useContext(DojoContext)
  const { season, actions } = useTournament()

  return (
    <>
      <Menu anchorEl={anchorEl} open={Boolean(anchorEl)} onClose={handleClose} sx={styles.menu}>
        <Box width={260} mt={0.5} display={'flex'} flexDirection={'column'} gap={0.5}>

          <Box px={2} display={'flex'} justifyContent={'space-between'} alignItems={'center'} mb={0.5}>
            <Typography color='primary' variant='h6'>
              Account
            </Typography>

            <Box display={'flex'} gap={0.5} alignItems={'center'}>
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="#FFE97F" height={12}><path d="M0 12v2h1v2h6V4h2v12h6v-2h1v-2h-2v2h-3V4h2V0h-2v2H9V0H7v2H5V0H3v4h2v10H2v-2z"></path></svg>
              <Typography color={'primary'} sx={{ fontSize: '12px' }}>
                {formatNumber(parseInt(dojo.balances.lords.toString()) / 10 ** 18)}
              </Typography>
            </Box>
          </Box>

          <Box display={'flex'} alignItems={'center'} justifyContent={'space-between'} boxSizing={'borderBox'} px={2}>
            <Box display={'flex'} alignItems={'center'} gap={2}>
              <PersonIcon fontSize='small' />

              <Typography>
                {dojo.customName || dojo.userName}
              </Typography>
            </Box>


            <IconButton onClick={() => { openNameDialog(true); handleClose() }}>
              <EditIcon fontSize='small' />
            </IconButton>
          </Box>
        </Box>

        <Divider sx={{ my: 1 }} />

        <MenuItem onClick={() => { window.open("https://github.com/provable-games/dark-shuffle", "_blank"); handleClose; }}>
          <ListItemIcon>
            <GitHubIcon fontSize="small" />
          </ListItemIcon>
          <ListItemText>
            Github
          </ListItemText>
        </MenuItem>

        <MenuItem onClick={() => { window.open("https://x.com/darkshuffle_gg", "_blank"); handleClose; }}>
          <ListItemIcon>
            <XIcon fontSize="small" />
          </ListItemIcon>
          <ListItemText>
            Twitter
          </ListItemText>
        </MenuItem>

        <Divider sx={{ my: 2 }} />

        <MenuItem disabled={season.end >= new Date() / 1000} onClick={() => { actions.submitScores(dojoConfig.seasonTournamentId) }}>
          <ListItemIcon>
            <SportsScoreIcon fontSize="small" />
          </ListItemIcon>
          <ListItemText>
            Submit Season
          </ListItemText>
        </MenuItem>

        <MenuItem disabled={season.end + season.submissionPeriod >= new Date() / 1000} onClick={() => { actions.distributePrizes(dojoConfig.seasonTournamentId) }}>
          <ListItemIcon>
            <EmojiEventsIcon fontSize="small" />
          </ListItemIcon>
          <ListItemText>
            Distribute Prizes
          </ListItemText>
        </MenuItem>

        <Divider sx={{ my: 2 }} />

        <MenuItem onClick={() => { disconnect(); handleClose(); }}>
          <ListItemIcon>
            <LogoutIcon fontSize="small" />
          </ListItemIcon>
          <ListItemText>
            Disconnect
          </ListItemText>
        </MenuItem>
      </Menu>
    </>
  );
}

export default ProfileMenu

const styles = {
  menu: {
    width: 300
  }
};
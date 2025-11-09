import TheatersIcon from '@mui/icons-material/Theaters';
import VisibilityIcon from '@mui/icons-material/Visibility';
import { Box, IconButton, Pagination, Tab, Tabs, Typography } from '@mui/material';
import React, { useEffect, useState } from 'react';
import { Scrollbars } from 'react-custom-scrollbars';
import { isMobile } from 'react-device-detect';
import { useIndexer } from '../../api/indexer';
import { useReplay } from '../../contexts/replayContext';

function Leaderboard() {
  const { getLeaderboard, getActiveLeaderboard, populateGameTokens } = useIndexer();

  const replay = useReplay()

  const [registrations, setRegistrations] = useState([])
  const [leaderboard, setLeaderboard] = useState([]);
  const [page, setPage] = useState(1)
  const [loading, setLoading] = useState(true)
  const [tab, setTab] = useState('one')

  const changeLeaderboard = (event, newValue) => {
    setLoading(true)
    setPage(1);
    setTab(newValue);
  }

  const handleChange = (event, newValue) => {
    setLoading(true)
    setPage(newValue);
  };

  useEffect(() => {
    async function fetchLeaderboard() {
      setLoading(true)

      let data = []
      if (tab === 'one') {
        data = await getLeaderboard(page - 1, registrations)
      } else {
        data = await getActiveLeaderboard(page - 1, registrations)
      }

      let games = (await populateGameTokens(data.map(game => game.game_id))).sort((a, b) => b.xp - a.xp)
      setLeaderboard(games ?? [])
      setLoading(false)
    }

    if (registrations.length > 0) {
      fetchLeaderboard()
    }
  }, [page, tab, registrations])

  return (
    <Box sx={styles.container}>
      <Tabs
        value={tab}
        indicatorColor="primary"
        onChange={changeLeaderboard}
      >
        <Tab value={'one'} label="Scores" />
        <Tab value={'two'} label="Active" />

        <Box sx={{ display: 'flex', width: '100%', alignItems: 'center', justifyContent: 'flex-end' }}>
          <Pagination count={Math.max(1, Math.floor(registrations.length / 10))} shape="rounded" color='primary' size='small' page={page} onChange={handleChange} />
        </Box>
      </Tabs>

      <Box sx={styles.header}>
        <Box width='25px' textAlign={'center'}>
        </Box>

        <Box width='30px' textAlign={'center'}>
          <Typography>#</Typography>
        </Box>

        <Box width={isMobile ? '135px' : '235px'}>
          <Typography>Player</Typography>
        </Box>

        <Box width='80px' textAlign={'center'}>
          <Typography>
            {tab === 'one' ? 'Score' : 'XP'}
          </Typography>
        </Box>
        <Box width='90px' textAlign={'center'}></Box>
      </Box>

      {loading && <Box />}

      <Scrollbars style={{ width: '100%', paddingBottom: '20px', height: '220px' }}>
        {!loading && React.Children.toArray(
          leaderboard.map((game, i) => {
            let rank = (page - 1) * 10 + i + 1

            return <>
              <Box sx={styles.row}>
                <Box width='25px' textAlign={'center'}>
                  {tab === 'one' && <IconButton onClick={() => replay.startReplay(game)}>
                    <TheatersIcon fontSize='small' color='primary' />
                  </IconButton>}

                  {tab === 'two' && <IconButton onClick={() => replay.spectateGame(game)}>
                    <VisibilityIcon fontSize='small' color='primary' />
                  </IconButton>}
                </Box>

                <Box width='30px' textAlign={'center'}>
                  <Typography>{rank}</Typography>
                </Box>

                <Box width={isMobile ? '135px' : '235px'}>
                  <Typography>{game.playerName}</Typography>
                </Box>

                <Box width='80px' textAlign={'center'}>
                  <Typography>{game.xp}</Typography>
                </Box>

                <Box width='90px' display={'flex'} gap={0.5} alignItems={'center'}>
                  {tab === 'one' && <Typography color={'primary'} sx={{ fontSize: '12px' }}>
                    {game.xp}
                  </Typography>}
                </Box>
              </Box>
            </>
          })
        )}
      </Scrollbars>
    </Box >
  )
}

export default Leaderboard

const styles = {
  container: {
    width: '100%',
    height: '100%',
  },
  header: {
    display: 'flex',
    justifyContent: 'space-between',
    p: 1,
    my: 1,
    opacity: 0.9
  },
  row: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    px: 1,
    opacity: 0.9
  }
}
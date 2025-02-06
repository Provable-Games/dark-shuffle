import CloseIcon from '@mui/icons-material/Close';
import { Box, Dialog, Typography } from '@mui/material';

function LoadingReplayDialog(props) {
  return (
    <Dialog
      open={true}
      maxWidth={'md'}
      PaperProps={{
        sx: { background: 'rgba(0, 0, 0, 0.98)', border: '2px solid #FFE97F' }
      }}
    >

      <Box sx={styles.container}>
        <Box sx={{ position: 'absolute', top: '10px', right: '10px' }} onClick={props.close}>
          <CloseIcon htmlColor='#FFF' sx={{ fontSize: '24px' }} />
        </Box>

        <Typography variant='h3' color={'primary'}>Loading Replay</Typography>

        <Box display={'flex'} alignItems={'baseline'}>
          <Typography variant='h6' color={'primary'}>Gathering Events</Typography>
          <div className='dotLoader' />
        </Box>

      </Box>

    </Dialog>
  )
}

export default LoadingReplayDialog

const styles = {
  container: {
    boxSizing: 'border-box',
    width: '400px',
    p: 4,
    gap: 4,
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    cursor: 'pointer',
    overflow: 'hidden',
    position: 'relative'
  },
}
import { Box, Button, Dialog, TextField, Typography } from '@mui/material';
import { motion } from "framer-motion";
import { useContext, useEffect, useState } from "react";
import { isBrowser, isMobile } from 'react-device-detect';
import background from "../../assets/images/gospel_scribe.png";
import { DojoContext } from '../../contexts/dojoContext';
import { fadeVariant } from "../../helpers/variants";
import { useSnackbar } from 'notistack';

function ChooseName(props) {
  const { open, close } = props
  const { enqueueSnackbar } = useSnackbar()

  const dojo = useContext(DojoContext)
  const [name, setName] = useState('')

  const applyName = () => {
    if (name.length < 2 || name.length > 31) {
      return enqueueSnackbar('Name must be between 2 and 31 characters', { variant: 'warning' })
    }

    localStorage.setItem('customName', name);
    dojo.setCustomName(name)
  }

  useEffect(() => {
    close(false);
  }, [dojo.customName])

  return (
    <Dialog
      open={open}
      onClose={() => close(false)}
      maxWidth={'lg'}
      PaperProps={{
        sx: { background: 'rgba(0, 0, 0, 1)', border: '2px solid #FFE97F', maxWidth: '98vw' }
      }}
    >
      <Box sx={isMobile ? styles.mobileWizardContainer : styles.wizardContainer}>
        <motion.div variants={fadeVariant} exit='exit' animate='enter'>
          <Box sx={styles.container} mt={isMobile ? 2 : 4}>

            <Box sx={styles.providerContainer}>
              <Typography color='white' variant='h4'>
                How would you like to be remembered?
              </Typography>

              <Box sx={{ mt: 1, display: 'flex', flexDirection: 'column', gap: 2 }}>
                <TextField
                  size="medium"
                  type='text'
                  placeholder="Enter name"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                />

                <Button variant='outlined' onClick={applyName} size='large'>
                  <Typography color='primary'>
                    Set Name
                  </Typography>
                </Button>
              </Box>
            </Box>

            {isBrowser && <Box display='flex' mr={5} mt={-2}>
              <img alt='' src={background} width={190} />
            </Box>}

          </Box>
        </motion.div>
      </Box>
    </Dialog>
  )
}

export default ChooseName

const styles = {
  wizardContainer: {
    display: 'flex',
    flexDirection: 'column',
    padding: '36px 30px',
    width: '700px',
    height: '300px',
  },
  mobileWizardContainer: {
    display: 'flex',
    flexDirection: 'column',
    boxSizing: 'border-box',
    padding: '8px',
    width: '100%',
    maxWidth: '500px',
    height: '300px',
    overflow: 'hidden'
  },
  container: {
    boxSizing: 'border-box',
    width: '100%',
    gap: 10,
    p: 4,
    display: 'flex',
    justifyContent: 'space-between',
    cursor: 'pointer',
    overflow: 'hidden'
  },
  providerContainer: {
    height: '100%',
    width: '300px',
    display: 'flex',
    flexDirection: 'column',
    gap: 2,
  }
}
import { LoadingButton } from '@mui/lab';
import { Box, Button, CircularProgress, Dialog, Typography } from '@mui/material';
import { motion } from "framer-motion";
import React, { useEffect, useState } from 'react';
import Scrollbars from 'react-custom-scrollbars';
import { getCardDetails } from '../../api/indexer';
import { fadeVariant } from "../../helpers/variants";

function DeckBuilder(props) {
  const { open, close, cardIds } = props

  const [loading, setLoading] = useState(true)
  const [cards, setCards] = useState([])

  async function fetchCardDetails() {
    setLoading(true)

    const cardDetails = await getCardDetails(cardIds)
    setCards(cardDetails ?? [])

    setLoading(false)
  }

  useEffect(() => {
    fetchCardDetails()
  }, [cardIds])

  return (
    <Dialog
      open={open}
      onClose={() => close(false)}
      maxWidth={'lg'}
      PaperProps={{
        sx: { background: 'rgba(0, 0, 0, 1)', border: '1px solid #FFE97F' }
      }}
    >
      <Box sx={styles.dialogContainer}>

        <motion.div variants={fadeVariant} exit='exit' animate='enter'>
          <Box sx={styles.container}>

            <Box sx={styles.cardContainer}>
              {cards.map((card) => (
                <Box key={card.id} sx={styles.card}>
                  <img src={card.image} alt={card.name} />
                </Box>
              ))}
            </Box>

          </Box>
        </motion.div>

      </Box>
    </Dialog>
  )
}

export default DeckBuilder

const styles = {
  dialogContainer: {
    display: 'flex',
    flexDirection: 'column',
    boxSizing: 'border-box',
    py: 2,
    px: 3,
    width: '1200px',
    height: '800px',
    overflow: 'hidden'
  },
  container: {
    boxSizing: 'border-box',
    width: '100%',
    display: 'flex',
    justifyContent: 'space-between',
    gap: 1.5,
  },
  cardContainer: {
    display: 'flex',
    flexDirection: 'column',
    gap: 1.5,
  },
}
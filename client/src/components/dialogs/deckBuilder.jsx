import CloseIcon from '@mui/icons-material/Close';
import { Box, Button, CircularProgress, Dialog, IconButton, Typography } from '@mui/material';
import { motion } from "framer-motion";
import React, { useEffect, useState } from 'react';
import { getCardDetails } from '../../api/indexer';
import { CardSize } from '../../helpers/cards';
import { fadeVariant } from "../../helpers/variants";
import Card from '../card';
import Overview from '../draft/overview';
import { Scrollbars } from 'react-custom-scrollbars';

function DeckBuilder(props) {
  const { open, close, cardIds, save, view } = props

  const [loading, setLoading] = useState(true)
  const [availableCards, setAvailableCards] = useState([])
  const [selectedCards, setSelectedCards] = useState([])

  async function fetchCardDetails() {
    setLoading(true)

    const cardDetails = await getCardDetails(view ? cardIds : Array.from({ length: 200 }, (_, i) => i + 1))
    setSelectedCards(cardDetails.filter(card => cardIds.includes(card.cardId)).sort((a, b) => a.cost - b.cost) ?? [])
    setAvailableCards(cardDetails.filter(card => !cardIds.includes(card.cardId)).sort((a, b) => a.cost - b.cost) ?? [])

    setLoading(false)
  }

  useEffect(() => {
    fetchCardDetails()
  }, [])

  const removeAllCards = () => {
    setAvailableCards(prev => [...prev, ...selectedCards].sort((a, b) => a.cost - b.cost))
    setSelectedCards([])
  }

  const removeCard = (cardId) => {
    let card = { ...selectedCards.find(card => card.cardId === cardId) }

    setAvailableCards(prev => [...prev, card].sort((a, b) => a.cost - b.cost))
    setSelectedCards(prev => prev.filter(card => card.cardId !== cardId))
  }

  const selectCard = (card) => {
    if (view) return;

    setSelectedCards(prev => [...prev, card].sort((a, b) => a.cost - b.cost))
    setAvailableCards(prev => prev.filter(c => c.cardId !== card.cardId))
  }

  return (
    <Dialog
      open={open}
      onClose={view ? close : () => { }}
      maxWidth={'lg'}
      PaperProps={{
        sx: { background: 'rgba(0, 0, 0, 1)', border: '1px solid #FFE97Fd1', maxWidth: '98vw' }
      }}
    >
      <Box sx={styles.dialogContainer}>

        <motion.div variants={fadeVariant} exit='exit' animate='enter'>
          {loading && <Box sx={styles.loadingContainer}>
            <CircularProgress />
          </Box>}

          {!loading && <Box sx={styles.container}>

            <Scrollbars style={styles.scrollbar}>
              {view
                ? <Typography variant='h6' textAlign='center' color='primary' mt={1}>
                  Cards list ({selectedCards.length})
                </Typography>
                : <Typography variant='h6' textAlign='center' color='primary' mt={1}>
                  Available Cards ({availableCards.length})
                </Typography>}

              <Box sx={styles.cards}>
                {(view ? selectedCards : availableCards).map((card) => (
                  <Box key={card.cardId} sx={styles.cardContainer} onClick={() => selectCard(card)}>
                    <Card card={card} />
                  </Box>
                ))}
              </Box>
            </Scrollbars>

            <Box sx={styles.overview}>
              <Scrollbars style={{ width: '100%', height: 'calc(100% - 60px)' }}>
                <Box display='flex' alignItems='center' justifyContent='space-between' px={1} mt={1}>
                  <Typography variant='h6' textAlign='center' color='primary'>
                    {view ? 'Card list' : 'Selected Cards'} ({selectedCards.length})
                  </Typography>

                  {!view && <IconButton onClick={removeAllCards} sx={{ p: 0, mr: 1 }}>
                    <CloseIcon color='error' fontSize='medium' />
                  </IconButton>}
                </Box>

                {selectedCards.length < 10 && <Typography color='error' px={1}>
                  10 Cards Required
                </Typography>}

                <Overview cards={selectedCards} deckBuilder={true} edit={!view} removeCard={removeCard} />
              </Scrollbars>

              {!view && <Box sx={styles.overviewOverlay}>
                <Button variant='outlined' color='secondary' sx={{ width: '100%' }} onClick={close}>
                  Cancel
                </Button>
                <Button disabled={selectedCards.length < 10} variant='contained' color='primary' sx={{ width: '100%' }} onClick={() => save(selectedCards.map(card => card.cardId))}>
                  Save Cards
                </Button>
              </Box>}

              {view && <Box sx={styles.overviewOverlay}>
                <Button variant='outlined' color='primary' sx={{ width: '100%', letterSpacing: '0.1em' }} onClick={close}>
                  BACK
                </Button>
              </Box>}
            </Box>

          </Box>}
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
    minWidth: '1137px',
    height: '800px',
    maxHeight: '90vh',
    overflow: 'hidden'
  },
  container: {
    boxSizing: 'border-box',
    width: '100%',
    display: 'flex',
    justifyContent: 'space-between',
  },
  mobileContainer: {
    boxSizing: 'border-box',
    width: '100%',
    display: 'flex',
    justifyContent: 'space-between',
    gap: 1.5,
  },
  cards: {
    display: 'flex',
    flexWrap: 'wrap',
    gap: 3,
    alignItems: 'center',
    width: '836px',
    py: 1,
    px: 2,
    boxSizing: 'border-box',
  },
  cardContainer: {
    height: CardSize.big.height,
    width: CardSize.big.width,
  },
  overview: {
    width: '300px',
    height: '800px',
    maxHeight: '90vh',
    borderLeft: '1px solid #FFE97F80',
    position: 'relative',
  },
  scrollbar: {
    width: '836px',
    height: '800px',
    maxHeight: '90vh',
  },
  overviewOverlay: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    background: 'rgba(0, 0, 0, 1)',
    borderTop: '1px solid #FFE97F80',
    padding: 1.5,
    display: 'flex',
    justifyContent: 'space-between',
    gap: 2,
  },
  loadingContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    height: '800px',
    maxHeight: '90vh',
  }
}
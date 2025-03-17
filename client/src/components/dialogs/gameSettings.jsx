import BookmarkIcon from '@mui/icons-material/Bookmark';
import CloseIcon from '@mui/icons-material/Close';
import { Box, Button, CircularProgress, Dialog, Input, Typography } from '@mui/material';
import { useEffect, useState } from 'react';
import { getSettings } from '../../api/indexer';
import { tierColors } from '../../helpers/cards';
import ArrowDropUpIcon from '@mui/icons-material/ArrowDropUp';
import ArrowDropDownIcon from '@mui/icons-material/ArrowDropDown';
import { DojoContext } from '../../contexts/dojoContext';
import { useContext } from 'react';
import { LoadingButton } from '@mui/lab';
import { useSnackbar } from 'notistack';

const DEFAULT_SETTINGS = {
  start_health: 50,
  persistent_health: true,
  max_branches: 3,
  enemy_attack: 2,
  enemy_health: 40,
  start_energy: 1,
  start_hand_size: 5,
  max_energy: 10,
  max_hand_size: 10,
  draw_amount: 1,
  auto_draft: false,
  draft_size: 20,
  card_ids: Array.from({ length: 90 }, (_, i) => i + 1),
  card_rarity_weights: {
    common: 5,
    uncommon: 4,
    rare: 3,
    epic: 2,
    legendary: 1
  },
}

function GameSettings(props) {
  const { view, settingsId } = props

  const dojo = useContext(DojoContext)
  const { enqueueSnackbar } = useSnackbar()

  const [gameSettings, setGameSettings] = useState(DEFAULT_SETTINGS)
  const [loading, setLoading] = useState(view)
  const [creating, setCreating] = useState(false)

  useEffect(() => {
    if (view) {
      fetchGameSettings(settingsId)
    }
  }, [view, settingsId])

  const fetchGameSettings = async (settingsId) => {
    setLoading(true)
    const settings = await getSettings(settingsId)
    setGameSettings(settings)
    setLoading(false)
  }

  const saveGameSettings = async () => {
    setCreating(true)
    let newSettings = { ...gameSettings }

    if (Object.values(newSettings.card_rarity_weights).every(weight => weight === newSettings.card_rarity_weights.common) && newSettings.card_rarity_weights.common !== 1) {
      newSettings.card_rarity_weights = {
        common: 1,
        uncommon: 1,
        rare: 1,
        epic: 1,
        legendary: 1
      }
    }

    const res = await dojo.executeTx([{
      contractName: "config_systems",
      entrypoint: "add_settings",
      calldata: [
        newSettings.start_health,
        newSettings.start_energy,
        newSettings.start_hand_size,
        newSettings.draft_size,
        newSettings.max_energy,
        newSettings.max_hand_size,
        newSettings.draw_amount,
        newSettings.card_ids,
        newSettings.card_rarity_weights,
        newSettings.auto_draft,
        newSettings.persistent_health,
        newSettings.max_branches,
        newSettings.enemy_attack,
        newSettings.enemy_health
      ]
    }], false)

    if (res) {
      console.log(res)
      enqueueSnackbar('Settings created successfully', { variant: 'success' })
      props.close()
    } else {
      enqueueSnackbar('Failed to create settings', { variant: 'error' })
    }

    setCreating(false)
  }

  const handleRarityWeightChange = (index, value) => {
    if (value > 10) {
      return;
    }

    let newWeights = [...gameSettings.cardRarityWeights];

    if (value < 1) {
      newWeights = newWeights.map((weight, i) => i === index ? weight : Math.min(10, weight + 1))
    } else {
      newWeights[index] = value;
    }

    setGameSettings({ ...gameSettings, cardRarityWeights: newWeights });
  };

  const renderSettingItem = (label, field, type, range) => {
    return (
      <Box sx={styles.settingContainer}>
        {label && <Typography color={'primary'}>{label}</Typography>}

        {type === 'boolean' && <Box height={'38px'} sx={styles.settingValueContainer} onClick={() => !view && setGameSettings({ ...gameSettings, [field]: !gameSettings[field] })}>
          <Typography color={'primary'}>{gameSettings[field] ? 'Yes' : 'No'}</Typography>
        </Box>}

        {type === 'number' && <Box sx={styles.settingValueContainer}>
          <Input disableUnderline={true} sx={{ color: '#FFE97F', width: '50px' }}
            inputProps={{ style: { textAlign: 'center', border: '1px solid #ffffff50', padding: '0', fontSize: '14px' } }}
            value={gameSettings[field]}
            disabled={view}
            onChange={(e) => setGameSettings({ ...gameSettings, [field]: e.target.value })}
            onBlur={() => setGameSettings({ ...gameSettings, [field]: Math.max(range[0], Math.min(range[1], gameSettings[field])) })}
          />
        </Box>}

        {type === 'cards' && <Box sx={styles.settingValueContainer}>
          <Typography sx={{ cursor: 'pointer', color: 'rgba(255, 255, 255, 0.7)', textDecoration: 'underline' }}>
            View
          </Typography>
        </Box>}

        {type === 'weights' && <Box sx={[styles.settingValueContainer, { justifyContent: 'space-between', width: '100%' }]}>
          {Object.keys(gameSettings.card_rarity_weights).map((item, index) => {
            let weight = gameSettings.card_rarity_weights[item]
            return (
              <Box sx={styles.rarityContainer} key={item}>
                <BookmarkIcon htmlColor={tierColors[item]} fontSize='small' />
                <Typography color={'primary'} fontSize={'13px'} sx={{ width: '33px' }}>
                  {`${((weight / Object.values(gameSettings.card_rarity_weights).reduce((a, b) => a + b, 0)) * 100).toFixed(0)}%`}
                </Typography>
                {!view && <Box sx={styles.arrowContainer}>
                  <ArrowDropUpIcon htmlColor={tierColors[item]} fontSize='small' onClick={() => handleRarityWeightChange(index, weight + 1)} />
                  <ArrowDropDownIcon htmlColor={tierColors[item]} fontSize='small' onClick={() => handleRarityWeightChange(index, weight - 1)} />
                </Box>}
              </Box>
            )
          })}
        </Box>}
      </Box>
    )
  }

  return (
    <Dialog
      open={true}
      onClose={props.close}
      maxWidth={'xl'}
      PaperProps={{
        sx: { background: 'rgba(0, 0, 0, 0.98)', border: '1px solid #FFE97F' }
      }}
    >

      <Box sx={styles.container}>
        <Box sx={{ position: 'absolute', top: '10px', right: '10px' }} onClick={props.close}>
          <CloseIcon htmlColor='#FFF' sx={{ fontSize: '24px' }} />
        </Box>

        <Typography variant='h4' color={'primary'} mb={1}>
          {view && `Settings #${settingsId}`}
        </Typography>

        {loading && <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '400px' }}>
          <CircularProgress />
        </Box>}

        {!loading && <Box sx={{ display: 'flex', gap: 5 }}>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
            <Typography variant='h6' color={'#f59100'}>Game</Typography>

            {renderSettingItem('Starting Health', 'start_health', 'number', [1, 200])}
            {renderSettingItem('Persistent Health', 'persistent_health', 'boolean')}

            <Typography variant='h6' color={'#f59100'}>Battle</Typography>

            {renderSettingItem('Starting Energy', 'start_energy', 'number', [1, 50])}
            {renderSettingItem('Starting Hand Size', 'start_hand_size', 'number', [1, 10])}
            {renderSettingItem('Maximum Energy', 'max_energy', 'number', [1, 50])}
            {renderSettingItem('Maximum Hand Size', 'max_hand_size', 'number', [1, 10])}
            {renderSettingItem('Cards Drawn per Turn', 'draw_amount', 'number', [1, 5])}
          </Box>

          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
            <Typography variant='h6' color={'#f59100'}>Draft</Typography>

            {renderSettingItem('Auto Draft', 'auto_draft', 'boolean')}
            {renderSettingItem('Draft Size', 'draft_size', 'number', [1, 50])}
            {renderSettingItem('Cards', 'card_ids', 'cards')}
            {renderSettingItem('', 'card_rarity_weights', 'weights')}

            <Typography variant='h6' color={'#f59100'}>Map</Typography>

            {renderSettingItem('Possible Branches', 'max_branches', 'number', [1, 3])}
            {renderSettingItem('Enemy Starting Attack', 'enemy_attack', 'number', [1, 10])}
            {renderSettingItem('Enemy Starting Health', 'enemy_health', 'number', [10, 200])}
          </Box>
        </Box>}

        {!view && <Box sx={styles.footer}>
          <LoadingButton loading={creating} variant='contained' color='primary' onClick={saveGameSettings} sx={{ width: '200px' }}>
            Create Settings
          </LoadingButton>
        </Box>}
      </Box>
    </Dialog>
  )
}

export default GameSettings

const styles = {
  container: {
    boxSizing: 'border-box',
    p: 2,
    pt: 1.5,
    gap: 1,
    display: 'flex',
    flexDirection: 'column',
    cursor: 'pointer',
    overflow: 'hidden',
    position: 'relative',
    width: '830px'
  },
  settingContainer: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: 2,
    px: 1,
    minHeight: '38px',
    border: '1px solid #FFE97F',
    width: '360px'
  },
  settingValueContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    minWidth: '50px',
  },
  rarityContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    width: '72px'
  },
  arrowContainer: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
  },
  footer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
    mt: 3
  }
}
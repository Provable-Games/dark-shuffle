import ArrowDropDownIcon from '@mui/icons-material/ArrowDropDown';
import ArrowDropUpIcon from '@mui/icons-material/ArrowDropUp';
import BookmarkIcon from '@mui/icons-material/Bookmark';
import CloseIcon from '@mui/icons-material/Close';
import FavoriteIcon from '@mui/icons-material/Favorite';
import { LoadingButton } from '@mui/lab';
import { Box, Button, CircularProgress, Dialog, Input, TextField, Typography } from '@mui/material';
import { useSnackbar } from 'notistack';
import { useContext, useEffect, useState } from 'react';
import { isMobile } from 'react-device-detect';
import { byteArray } from "starknet";
import { getSettings } from '../../api/indexer';
import sword from '../../assets/images/sword.png';
import { DojoContext } from '../../contexts/dojoContext';
import { tierColors } from '../../helpers/cards';
import DeckBuilder from './deckBuilder';
import { GameContext } from '../../contexts/gameContext';
import { useAccount, useConnect } from '@starknet-react/core';
import PlayArrowIcon from '@mui/icons-material/PlayArrow';
import EditIcon from '@mui/icons-material/Edit';

const DEFAULT_SETTINGS = {
  name: '',
  description: '',
  starting_health: 50,
  persistent_health: true,
  possible_branches: 3,
  level_depth: 5,
  enemy_attack_min: 2,
  enemy_attack_max: 3,
  enemy_health_min: 30,
  enemy_health_max: 50,
  enemy_attack_scaling: 1,
  enemy_health_scaling: 5,
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
  const { view, settingsId, closeList, inGame } = props

  const dojo = useContext(DojoContext)
  const { enqueueSnackbar } = useSnackbar()
  const gameContext = useContext(GameContext)
  const { account } = useAccount()
  const { connect, connectors } = useConnect()

  const [gameSettings, setGameSettings] = useState(DEFAULT_SETTINGS)
  const [loading, setLoading] = useState(view)
  const [creating, setCreating] = useState(false)
  const [step, setStep] = useState(1)
  const [name, setName] = useState('')
  const [showError, setShowError] = useState(false)
  const [description, setDescription] = useState('')
  const [deckBuilder, openDeckBuilder] = useState(false)
  const [editing, setEditing] = useState(view ? false : true)

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
    if (!name || name.length > 31) {
      setShowError(true)
      return
    }

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

    try {
      const res = await dojo.executeTx([{
        contractName: "config_systems",
        entrypoint: "add_settings",
        calldata: [
          name,
          byteArray.byteArrayFromString(description),
          newSettings.starting_health,
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
          newSettings.possible_branches,
          newSettings.level_depth,
          newSettings.enemy_attack_min,
          newSettings.enemy_attack_max,
          newSettings.enemy_health_min,
          newSettings.enemy_health_max,
          newSettings.enemy_attack_scaling,
          newSettings.enemy_health_scaling,
        ]
      }], false)

      if (res) {
        props.refetch()
        props.close()
      } else {
        enqueueSnackbar('Failed to create settings', { variant: 'error' })
      }
    } catch (error) {

    }

    setCreating(false)
  }

  const handleRarityWeightChange = (rarity, value) => {
    let newWeights = { ...gameSettings.card_rarity_weights };

    if (value > 10) {
      newWeights = Object.keys(newWeights).reduce((acc, key) => {
        acc[key] = key === rarity ? 10 : Math.max(newWeights[key] - 1, 1);
        return acc;
      }, {});
    } else if (value < 1) {
      newWeights = Object.keys(newWeights).reduce((acc, key) => {
        acc[key] = key === rarity ? 1 : Math.min(newWeights[key] + 1, 10);
        return acc;
      }, {});
    } else {
      newWeights[rarity] = value;
    }

    setGameSettings({ ...gameSettings, card_rarity_weights: newWeights });
  };

  const renderSettingItem = (label, field, type, range) => {
    return (
      <Box sx={styles.settingContainer}>
        {label && <Typography color={'primary'}>
          {label} {type === 'cards' && `(${gameSettings[field].length})`}
        </Typography>}

        {type === 'boolean' && <Box height={'38px'} sx={styles.settingValueContainer} onClick={() => editing && setGameSettings({ ...gameSettings, [field]: !gameSettings[field] })}>
          <Typography color={'primary'}>{gameSettings[field] ? 'Yes' : 'No'}</Typography>
        </Box>}

        {type === 'number' && <Box sx={styles.settingValueContainer}>
          <Input disableUnderline={true} sx={{ color: '#FFE97F', width: '50px' }}
            inputProps={{ style: { textAlign: 'center', border: '1px solid #ffffff50', padding: '0', fontSize: '14px' } }}
            value={gameSettings[field]}
            disabled={!editing}
            onChange={(e) => setGameSettings({ ...gameSettings, [field]: e.target.value })}
            onBlur={() => setGameSettings({ ...gameSettings, [field]: Math.max(range[0], Math.min(range[1], gameSettings[field])) })}
          />
        </Box>}

        {type === 'range' && <Box sx={styles.settingValueContainer} gap={0.5}>
          <Input disableUnderline={true} sx={{ color: '#FFE97F', width: '50px' }}
            inputProps={{ style: { textAlign: 'center', border: '1px solid #ffffff50', padding: '0', fontSize: '14px' } }}
            value={gameSettings[field[0]]}
            disabled={!editing}
            onChange={(e) => setGameSettings({ ...gameSettings, [field[0]]: e.target.value })}
            onBlur={() => setGameSettings({ ...gameSettings, [field[0]]: Math.max(range[0], Math.min(range[1], gameSettings[field[0]])) })}
          />
          <Typography color={'primary'}>{`-`}</Typography>
          <Input disableUnderline={true} sx={{ color: '#FFE97F', width: '50px' }}
            inputProps={{ style: { textAlign: 'center', border: '1px solid #ffffff50', padding: '0', fontSize: '14px' } }}
            value={gameSettings[field[1]]}
            disabled={!editing}
            onChange={(e) => setGameSettings({ ...gameSettings, [field[1]]: e.target.value })}
            onBlur={() => setGameSettings({ ...gameSettings, [field[1]]: Math.max(range[0], Math.min(range[1], gameSettings[field[1]])) })}
          />
        </Box>}

        {type === 'scaling' && <Box sx={styles.settingValueContainer} gap={2}>
          <Input disableUnderline={true} sx={{ color: '#FFE97F', width: '50px' }}
            inputProps={{ style: { textAlign: 'center', border: '1px solid #ffffff50', padding: '0', fontSize: '14px' } }}
            value={gameSettings[field[0]]}
            disabled={!editing}
            onChange={(e) => setGameSettings({ ...gameSettings, [field[0]]: e.target.value })}
            onBlur={() => setGameSettings({ ...gameSettings, [field[0]]: Math.max(range[0][0], Math.min(range[0][1], gameSettings[field[0]])) })}
            startAdornment={<img src={sword} alt='sword' style={{ width: '15px', height: '15px', paddingRight: '2px' }} />}
          />
          <Input disableUnderline={true} sx={{ color: '#FFE97F', width: '50px' }}
            inputProps={{ style: { textAlign: 'center', border: '1px solid #ffffff50', padding: '0', fontSize: '14px' } }}
            value={gameSettings[field[1]]}
            disabled={!editing}
            onChange={(e) => setGameSettings({ ...gameSettings, [field[1]]: e.target.value })}
            onBlur={() => setGameSettings({ ...gameSettings, [field[1]]: Math.max(range[1][0], Math.min(range[1][1], gameSettings[field[1]])) })}
            startAdornment={<FavoriteIcon htmlColor={'red'} sx={{ fontSize: '16px', pr: '2px' }} />}
          />
        </Box>}

        {type === 'cards' && <Box sx={styles.settingValueContainer}>
          <Typography sx={{ cursor: 'pointer', color: 'rgba(255, 255, 255, 0.7)', textDecoration: 'underline' }} onClick={() => openDeckBuilder(true)}>
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
                  {`${Math.round((weight / Object.values(gameSettings.card_rarity_weights).reduce((a, b) => a + b, 0)) * 100)}%`}
                </Typography>
                {editing && <Box sx={styles.arrowContainer}>
                  <ArrowDropUpIcon htmlColor={tierColors[item]} fontSize='small' onClick={() => handleRarityWeightChange(item, weight + 1)} />
                  <ArrowDropDownIcon htmlColor={tierColors[item]} fontSize='small' onClick={() => handleRarityWeightChange(item, weight - 1)} />
                </Box>}
              </Box>
            )
          })}
        </Box>}
      </Box>
    )
  }

  const saveDeck = (cardIds) => {
    setGameSettings({ ...gameSettings, card_ids: cardIds })
    openDeckBuilder(false)
  }

  const trySettings = async () => {
    if (!account) {
      connect({ connector: connectors.find(conn => conn.id === "controller") })
      return
    }

    props.close()
    if (closeList) {
      closeList()
    }

    gameContext.actions.mintFreeGame(settingsId)
  }

  return (
    <Dialog
      open={true}
      onClose={!editing ? props.close : () => { }}
      maxWidth={'xl'}
      PaperProps={{
        sx: { background: 'rgba(0, 0, 0, 1)', border: '1px solid #FFE97F', maxWidth: '98vw' }
      }}
    >

      <Box sx={styles.container}>
        <Box sx={{ position: 'absolute', top: '10px', right: '10px' }} onClick={props.close}>
          <CloseIcon htmlColor='#FFF' sx={{ fontSize: '24px' }} />
        </Box>

        {(!editing && !inGame) && <Box sx={{ position: 'absolute', top: '7px', right: '50px', display: 'flex', gap: 1 }} onClick={() => setEditing(true)}>
          <Button variant='outlined' color='primary' size='small' startIcon={<EditIcon color='primary' />}>
            Edit
          </Button>

          <Button variant='outlined' color='primary' size='small' startIcon={<PlayArrowIcon color='primary' />} onClick={trySettings}>
            Try Settings
          </Button>
        </Box>}

        <Typography variant='h4' color={'primary'}>
          {!editing ? gameSettings.name : step === 2 ? 'Create Settings' : ``}
        </Typography>

        {loading && <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '400px', width: '800px' }}>
          <CircularProgress />
        </Box>}

        {!loading && step === 1 && <Box sx={{ display: 'flex', gap: isMobile ? 1 : 5, flexWrap: 'wrap' }}>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
            <Typography variant='h6' color={'#f59100'}>Game</Typography>

            {renderSettingItem('Auto Draft', 'auto_draft', 'boolean')}
            {renderSettingItem('Persistent Health', 'persistent_health', 'boolean')}
            {renderSettingItem('Starting Health', 'starting_health', 'number', [1, 200])}

            <Typography variant='h6' color={'#f59100'}>Battle</Typography>

            {renderSettingItem('Starting Energy', 'start_energy', 'number', [1, 50])}
            {renderSettingItem('Starting Hand Size', 'start_hand_size', 'number', [1, 10])}
            {renderSettingItem('Maximum Energy', 'max_energy', 'number', [1, 50])}
            {renderSettingItem('Maximum Hand Size', 'max_hand_size', 'number', [1, 10])}
            {renderSettingItem('Cards Drawn per Turn', 'draw_amount', 'number', [1, 5])}
          </Box>

          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
            <Typography variant='h6' color={'#f59100'}>Draft</Typography>

            {renderSettingItem('Draft Size', 'draft_size', 'number', [1, 50])}
            {renderSettingItem('Cards', 'card_ids', 'cards')}
            {renderSettingItem('', 'card_rarity_weights', 'weights')}

            <Typography variant='h6' color={'#f59100'}>Map</Typography>

            {renderSettingItem('Possible Branches', 'possible_branches', 'number', [1, 3])}
            {renderSettingItem('Level Depth', 'level_depth', 'number', [1, 5])}
            {renderSettingItem('Enemy Attack', ['enemy_attack_min', 'enemy_attack_max'], 'range', [1, 10])}
            {renderSettingItem('Enemy Health', ['enemy_health_min', 'enemy_health_max'], 'range', [10, 200])}
            {renderSettingItem('Enemy Scaling', ['enemy_attack_scaling', 'enemy_health_scaling'], 'scaling', [[1, 10], [1, 50]])}
          </Box>
        </Box>}

        {!loading && step === 2 && <>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }} mt={2}>
            <Typography variant='h6' color={'#f59100'}>
              Name
            </Typography>

            <TextField
              size="medium"
              type='text'
              value={name}
              onChange={(e) => setName(e.target.value)}
              fullWidth
              error={showError}
              helperText={showError && name.length > 31 ? 'Name must be less than 31 characters' : ''}
            />

            <Typography variant='h6' color={'#f59100'}>
              Description
            </Typography>

            <TextField
              size="medium"
              type='text'
              multiline
              rows={6}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              fullWidth
            />
          </Box>
        </>}

        {editing && <Box sx={styles.footer}>
          {step === 1 && <Button variant='contained' color='primary' onClick={() => setStep(2)} sx={{ width: '200px' }}>
            Continue
          </Button>}

          {step === 2 &&
            <Box sx={{ display: 'flex', gap: 2 }}>
              <Button variant='outlined' color='secondary' onClick={() => setStep(1)} sx={{ width: '150px' }}>
                Back
              </Button>

              <LoadingButton loading={creating} variant='contained' color='primary' onClick={saveGameSettings} sx={{ width: '200px' }}>
                Create Settings
              </LoadingButton>
            </Box>
          }
        </Box>}
      </Box>

      {deckBuilder && <DeckBuilder open={deckBuilder} close={() => openDeckBuilder(false)} cardIds={gameSettings.card_ids} view={!editing} save={saveDeck} />}
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
    justifyContent: 'space-between',
    cursor: 'pointer',
    position: 'relative',
    minHeight: '520px',
    maxWidth: '98vw',
    overflow: isMobile ? 'scroll' : 'hidden'
  },
  settingContainer: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: 2,
    px: 1,
    minHeight: '38px',
    border: '1px solid #FFE97F',
    width: '360px',
    maxWidth: 'calc(100vw - 50px)'
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
    width: isMobile ? '17vw' : '72px'
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
    mt: 3
  }
}
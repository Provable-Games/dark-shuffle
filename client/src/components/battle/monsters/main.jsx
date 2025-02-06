import FavoriteIcon from '@mui/icons-material/Favorite';
import { Box, Typography } from "@mui/material";
import React from "react";
import { isMobile } from 'react-device-detect';
import sword from "../../../assets/images/sword.png";
import { fetch_card_image } from '../../../helpers/cards';
import { EnemyHealthBar } from '../../../helpers/styles';
import { normalise } from '../../../helpers/utilities';

export default function MonsterMain(props) {
  const { monster } = props

  return <>
    <EnemyHealthBar variant="determinate" value={normalise(monster.health, monster.startHealth)} />

    <Box sx={styles.imageContainer}>
      {<img alt='' src={fetch_card_image(monster.name)} height={'100%'} />}
    </Box>

    <Box sx={styles.bottomContainer}>
      <Box sx={{ display: 'flex', alignItems: 'center' }}>
        <Typography variant="h6" fontSize={isMobile && '14px'}>
          {monster.attack}
        </Typography>

        <img alt='' src={sword} height={isMobile ? 20 : 24} width={isMobile ? 20 : 24} />
      </Box>

      <Box>
        <Typography variant="subtitle1" fontSize={isMobile ? '13px' : '14px'}>
          {monster.monsterType}
        </Typography>
      </Box>

      <Box sx={{ display: 'flex', alignItems: 'center' }}>
        <Typography variant="h6" fontSize={isMobile && '14px'}>
          {monster.health}
        </Typography>

        <FavoriteIcon htmlColor="red" fontSize={isMobile ? 'small' : 'small'} />
      </Box>
    </Box>
  </>
}

const styles = {
  imageContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
    height: '70%'
  },
  bottomContainer: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
}
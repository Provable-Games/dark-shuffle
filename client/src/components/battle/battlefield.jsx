import { Box, Typography } from "@mui/material";
import React, { useContext } from "react";
import Scrollbars from "react-custom-scrollbars";
import { isBrowser, isMobile } from 'react-device-detect';
import { GET_MONSTER } from "../../battle/monsterUtils";
import { BattleContext } from '../../contexts/battleContext';
import { GameContext } from "../../contexts/gameContext";
import Adventurer from './adventurer';
import Creature from "./creature";
import DeathDialog from './death';
import Monster from "./monster";
import { CustomTooltip } from "../../helpers/styles";
import { LoadingButton } from "@mui/lab";

function Battlefield(props) {
  const game = useContext(GameContext)
  const battle = useContext(BattleContext)

  let monsterName = game.getState.map.find(node => node.nodeId === game.values.lastNodeId)?.monsterName
  const monster = { ...GET_MONSTER(battle.state.values.monsterId, monsterName), attack: battle.state.values.monsterAttack, health: battle.state.values.monsterHealth }

  return <Box sx={styles.container} height={isMobile ? '98%' : '95%'}>

    {game.score && <DeathDialog />}

    <Box sx={isMobile ? styles.enemyContainerMobile : styles.enemyContainer} height={isMobile ? '45%' : '40%'}>

      <Monster monster={monster} />

    </Box>

    {isMobile && <Box sx={{ m: 2, display: 'flex', justifyContent: 'flex-end' }}>
      <CustomTooltip title={<Box mb={1}>
        <Typography color="primary">End Turn</Typography>
        <Typography mt={0.5}>Your creatures attack. Monster perform its ability and attack. You replenish energy.</Typography>
      </Box>
      }>
        <LoadingButton variant='outlined' size='large' sx={{ fontSize: '14px', letterSpacing: '1px' }}
          loading={battle.state.pendingTx}
          onClick={() => battle.actions.endTurn()}
        >
          End Turn
        </LoadingButton>
      </CustomTooltip>
    </Box>}

    {isMobile && <Box sx={styles.myContainerMobile} height={'30%'} justifyContent={battle.state.board.length > 3 ? 'flex-start' : 'center'}>

      {
        React.Children.toArray(
          battle.state.board.map((creature, i) => {
            return <Creature
              pos={i}
              creature={creature}
            />
          })
        )
      }

    </Box>
    }

    {
      isBrowser && <Box sx={[styles.myContainer]} height={'35%'}>

        {React.Children.toArray(
          battle.state.board.map((creature, i) => {
            return <Creature
              key={creature.id}
              pos={i}
              creature={creature}
            />
          })
        )}

      </Box>
    }

    {isBrowser && <Box sx={styles.kingContainer}>

      <Adventurer />

    </Box >}
  </Box >
}

export default Battlefield

const styles = {
  container: {
    boxSizing: 'border-box',
    width: '100%',
    borderRadius: '4px',
    background: 'rgba(0, 0, 0, 0.6)',
  },
  enemyContainer: {
    width: '100%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 4,
  },
  enemyContainerMobile: {
    width: '100%',
    display: 'flex',
    alignItems: 'flex-end',
    justifyContent: 'center',
    gap: 4,
    pb: 2
  },
  myContainer: {
    width: '100%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 2,
  },
  myContainerMobile: {
    width: '100%',
    display: 'flex',
    alignItems: 'center',
    gap: 2,
    overflowX: 'auto',
    boxSizing: 'border-box',
    px: 1
  },
  targetIcon: {
    width: '35px',
    height: '35px',
    position: 'absolute',
    top: '-25px',
    left: 'calc(50%-18px)',
  },
  kingContainer: {
    width: '100%',
    height: '20%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center'
  }
}
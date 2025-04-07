import { Box, Typography } from "@mui/material";
import { BarChart } from '@mui/x-charts';
import React, { useContext } from "react";
import { DraftContext } from "../../contexts/draftContext";
import { useState } from "react";
import { useEffect } from "react";
import { types } from "../../helpers/cards";
import { GameContext } from "../../contexts/gameContext";

function DraftStats() {
  const game = useContext(GameContext)
  const { gameSettings } = game.getState

  const draft = useContext(DraftContext)
  const { cards } = draft.getState

  const [manaCurve, setManaCurve] = useState({});

  useEffect(() => {
    let copy = {
      [types.CREATURE]: [0, 0, 0, 0, 0, 0],
      [types.SPELL]: [0, 0, 0, 0, 0, 0]
    }

    cards.forEach(card => {
      copy[card.category][card.cost] += 1;
    })

    setManaCurve(copy)
  }, [cards]);

  const typeCount = cards.reduce((acc, card) => {
    const type = card.category === types.CREATURE ? card.cardType : card.category
    acc[type] = (acc[type] || 0) + 1
    return acc
  }, {})

  return <Box sx={styles.container}>

    <Box width='120px'>
      <Typography variant="h6">
        Draft
      </Typography>
      <Typography variant="h2" color='primary' mb={1}>
        {cards.length}/{gameSettings.draft_size}
      </Typography>
    </Box>

    <Box pb={window.innerHeight < 700 ? 0 : 2}>
      <BarChart
        width={400}
        height={window.innerHeight < 700 ? 190 : 225}
        slotProps={{
          legend: {
            hidden: true
          }
        }}
        leftAxis={null}
        yAxis={[{ disableLine: true, disableTicks: true }]}
        xAxis={[
          {
            data: ['0', '1', '2', '3', '4', '5'],
            scaleType: 'band',
            hideTooltip: true
          },
        ]}
        series={Object.entries(manaCurve).map(([key, value]) => {
          return {
            label: key,
            data: value,
            stack: 'A'
          }
        })}
        colors={['#FFE97F']}
      />
    </Box>

    <Box sx={styles.tagContainer}>

      {React.Children.toArray(
        Object.keys(typeCount).map((type, i) => {
          const count = typeCount[type]

          if (count > 0) {
            return <Box sx={styles.chip}>
              <Typography>
                {`${count} ${type}`}
              </Typography>
            </Box>
          }
        })
      )}

    </Box>

  </Box>
}

export default DraftStats

const styles = {
  container: {
    width: '100%',
    height: '100%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    p: 1,
    boxSizing: 'border-box'
  },
  tagContainer: {
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    gap: 1,
    height: '100%',
    flexWrap: 'wrap',
    width: '120px',
    alignItems: 'center'
  },
  chip: {
    border: '1px solid #FFE97F',
    borderRadius: '12px',
    padding: '4px 12px',
    display: 'flex',
    minWidth: '80px',
  },
}
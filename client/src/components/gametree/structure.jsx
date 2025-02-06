import FavoriteIcon from '@mui/icons-material/Favorite';
import StarIcon from '@mui/icons-material/Star';
import { LoadingButton } from '@mui/lab';
import { Box, Menu, Typography } from '@mui/material';
import React, { useContext, useEffect, useRef, useState } from 'react';
import { Scrollbars } from 'react-custom-scrollbars';
import skull from "../../assets/images/skull.png";
import sword from "../../assets/images/sword.png";
import { GET_MONSTER } from '../../battle/monsterUtils';
import { GameContext } from '../../contexts/gameContext';
import { CardSize, fetch_card_image, fetchBeastTypeImage } from '../../helpers/cards';
import { LargeCustomTooltip } from '../../helpers/styles';
import { isMobile } from 'react-device-detect';
import { useReplay } from '../../contexts/replayContext';

const INACTIVE_OPACITY = 0.5

function Structure(props) {
  const replay = useReplay()
  const game = useContext(GameContext)

  const { map } = game.getState
  const [tree, buildTree] = useState([])
  const scrollbarRef = useRef(null);

  const [anchorEl, setAnchorEl] = useState(null);
  const [selectedNode, setSelectedNode] = useState(null);

  const handleClick = (event, node) => {
    if (node.active) {
      setAnchorEl(event.currentTarget);
      setSelectedNode(node);
    }
  };

  const handleClose = () => {
    setAnchorEl(null);
    setSelectedNode(null);
  };

  const scrollContainer = () => {
    if (scrollbarRef.current) {
      scrollbarRef.current.view.scrollTo({
        left: (1200 - window.innerWidth + 55) / 2,
        top: scrollbarRef.current.getScrollHeight(),
        behavior: 'smooth'
      });
    }
  };

  const scrollToCenter = () => {
    if (scrollbarRef.current) {
      scrollbarRef.current.view.scrollTo({
        left: (1200 - window.innerWidth + 55) / 2,
        behavior: 'smooth'
      });
    }
  }

  useEffect(() => {
    if (tree.length > 0 && game.values.mapDepth < 3 && scrollbarRef.current) {
      scrollContainer()
    } else if (isMobile) {
      scrollToCenter()
    }
  }, [tree])

  useEffect(() => {
    let endNode = map[map.length - 1]
    let sectionStartNodes = map.filter(node => node.parents.includes(map[0].nodeId))

    buildTree(sectionStartNodes.map((startNode, i) => {
      let currentNodes = [startNode]
      let generatedSection = []

      while (currentNodes[0].nodeId !== endNode.nodeId) {
        generatedSection.push(currentNodes)
        currentNodes = map.filter(node => currentNodes.find(currentNode => node.parents.includes(currentNode.nodeId)))
      }

      return generatedSection.reverse()
    }))
  }, [map])

  function RenderBattleMenu() {
    let monster = GET_MONSTER(selectedNode?.monsterId, selectedNode?.monsterName)

    return <Menu
      anchorEl={anchorEl}
      open={Boolean(anchorEl)}
      onClose={handleClose}
      anchorOrigin={{ vertical: 'top', horizontal: 'center' }}
      transformOrigin={{ vertical: 'bottom', horizontal: 'center' }}
      sx={{ zIndex: 100000 }}
    >

      <Box sx={styles.battleMenu}>

        <Box sx={styles.tooltipContainer}>
          {monster.abilities}

          <Box sx={{ mt: 2 }}>
            <LoadingButton loading={props.selectingNode} fullWidth variant='outlined'
              onClick={() => props.selectNode(selectedNode?.nodeId, 'battle')}
              sx={{ fontSize: '14px', letterSpacing: '1px', textTransform: 'none' }}
            >
              Battle
            </LoadingButton>
          </Box>
        </Box>

      </Box>

    </Menu>
  }

  function nodeStyle(node) {
    if (game.values.replay && node.nodeId === replay.getMapSelection()) {
      return { opacity: 1, borderColor: 'green' }
    }

    if (node.active || node.status !== 0) {
      return { opacity: 1, borderColor: '#FFE97F' }
    }

    return { opacity: INACTIVE_OPACITY }
  }

  function connectorStyle(node, nextNode, direction, type) {
    if (direction !== null && node.active && !node.status && direction >= 0) {
      return { opacity: INACTIVE_OPACITY }
    }

    if (nextNode && (nextNode.active || nextNode.status !== 0) && node.status) {
      return { opacity: 1, borderColor: '#FFE97F', background: ['vertical', 'horizontal'].includes(type) ? '#FFE97F' : 'inherit' }
    }

    if ((node.active || node.status !== 0) && direction === null) {
      return { opacity: 1, borderColor: '#FFE97F', background: ['vertical', 'horizontal'].includes(type) ? '#FFE97F' : 'inherit' }
    }

    return { opacity: INACTIVE_OPACITY }
  }

  function RenderTopLine() {
    let endNode = map[map.length - 1]
    let connectedToEndNode = tree.flat(2).filter(node => endNode.parents.includes(node.nodeId))

    function getStyles(line) {
      if (tree.length === 1) {
        if (line < 5 || line > 6) {
          return { opacity: 0 }
        }

        if (connectedToEndNode.length === 1) {
          return { opacity: 0 }
        }
      }

      if (tree.length === 2) {
        if (line < 3 || line > 8) {
          return { opacity: 0 }
        }

        if (line === 3 && connectedToEndNode.filter(node => node.section === 0).length === 1) {
          return { opacity: 0 }
        }

        if (line === 8 && connectedToEndNode.filter(node => node.section === 1).length === 1) {
          return { opacity: 0 }
        }

      }

      if (tree.length === 3) {
        if (line < 1 || line > 10) {
          return { opacity: 0 }
        }

        if (line === 1 && connectedToEndNode.filter(node => node.section === 0).length === 1) {
          return { opacity: 0 }
        }

        if (line === 10 && connectedToEndNode.filter(node => node.section === 2).length === 1) {
          return { opacity: 0 }
        }
      }

      if (!endNode.active) {
        return { opacity: INACTIVE_OPACITY }
      }

      let activeNode = connectedToEndNode.find(node => node.status !== 0 || node.active)
      let sectionLength = connectedToEndNode.filter(node => node.section === activeNode.section).length
      let sectionIndex = connectedToEndNode.filter(node => node.section === activeNode.section).findIndex(node => node.nodeId === activeNode.nodeId)

      if (tree.length === 3) {
        if (activeNode.section === 0) {
          if ((sectionLength === 2 && line > sectionIndex * 2 && line < 6) || (sectionLength === 1 && line > 1 && line < 6)) {
            return { opacity: 1, background: '#FFE97F' }
          }
        }

        if (activeNode.section === 1) {
          if ((sectionLength === 2 && line === 5 + sectionIndex)) {
            return { opacity: 1, background: '#FFE97F' }
          }
        }

        if (activeNode.section === 2) {
          if ((sectionLength === 2 && line < (9 + sectionIndex * 2) && line > 5) || (sectionLength === 1 && line < 11 && line > 5)) {
            return { opacity: 1, background: '#FFE97F' }
          }
        }
      }

      if (tree.length === 2) {
        if (activeNode.section === 0) {
          if ((sectionLength === 2 && line > (2 + sectionIndex * 2) && line < 6) || (sectionLength === 1 && line > 3 && line < 6)) {
            return { opacity: 1, background: '#FFE97F' }
          }
        }

        if (activeNode.section === 1) {
          if ((sectionLength === 2 && line < (7 + sectionIndex * 2) && line > 5) || (sectionLength === 1 && line < 9 && line > 5)) {
            return { opacity: 1, background: '#FFE97F' }
          }
        }
      }

      if (tree.length === 1) {
        if (sectionLength === 2 && line === 5 + sectionIndex) {
          return { opacity: 1, background: '#FFE97F' }
        }
      }

      return { opacity: INACTIVE_OPACITY }
    }

    return <>
      <Box sx={{ height: '25px', width: '1px', background: endNode.active ? '#FFE97F' : '#FFF', opacity: endNode.active ? 1 : INACTIVE_OPACITY }} />

      <Box sx={{ display: 'flex', flexDirection: 'row', width: `100%` }}>
        {React.Children.toArray(
          Array(12).fill(0).map((_, index) => {
            return <Box sx={{
              width: '100px',
              height: '1px',
              background: '#FFF',
              ...getStyles(index)
            }} />
          })
        )}
      </Box>
    </>
  }

  function RenderConnector(node, type, number, nodeStyles) {
    let nextNode = number !== null ? map.filter(_node => _node.parents.includes(node.nodeId))[number] : null

    if (type === 'vertical') {
      return <Box sx={{ width: '1px', background: '#FFF', ...nodeStyles, ...connectorStyle(node, nextNode, number, type) }} />
    }

    if (type === 'horizontal') {
      return <Box sx={{ height: '1px', background: '#FFF', ...nodeStyles, ...connectorStyle(node, nextNode, number, type) }} />
    }

    if (type === 'curved') {
      return <Box sx={[styles.curvedLine, { ...nodeStyles, ...connectorStyle(node, nextNode, number) }]} />
    }

    if (type === 'curvedReverse') {
      return <Box sx={[styles.curvedLineReverse, { ...nodeStyles, ...connectorStyle(node, nextNode, number) }]} />
    }
  }

  function RenderMonsterCircle(node) {
    let monster = GET_MONSTER(node.monsterId, node.monsterName)

    return <Box sx={styles.circleContainer}>
      <LargeCustomTooltip leaveDelay={200} position={'top'} title={
        <Box sx={styles.tooltipContainer}>
          {monster.abilities}

          {node.active && <Box sx={{ mt: 2 }}>
            <LoadingButton loading={props.selectingNode} fullWidth variant='outlined'
              onClick={(event) => { props.selectNode(node.nodeId, 'battle'); handleClick(event, node); }}
              sx={{ fontSize: '14px', letterSpacing: '1px', textTransform: 'none' }}
            >
              Battle
            </LoadingButton>
          </Box>}
        </Box>
      }>
        <Box sx={[styles.monsterCircle, nodeStyle(node), (selectedNode?.nodeId === node.nodeId && node.active) && { boxShadow: '0 0 5px 1px rgba(255, 255, 255, 0.7)' }]}
          onClick={(event) => handleClick(event, node)}>
          <Box sx={styles.typeContainer}>
            {fetchBeastTypeImage(monster.monsterType)}
          </Box>

          <Box sx={{ pt: '4%', width: '100%', height: '70%', display: 'flex', justifyContent: 'center', opacity: node.status !== 0 ? 0.5 : 1 }}>
            {<img alt='' src={fetch_card_image(monster.name)} height={'100%'} />}
          </Box>

          <Box sx={{ display: 'flex', width: '100%', justifyContent: 'space-between' }}>
            <Box sx={{ display: 'flex', alignItems: 'center' }}>
              <Typography>
                {node.attack}
              </Typography>

              <img alt='' src={sword} height={18} width={18} />
            </Box>

            <Box sx={{ display: 'flex', alignItems: 'center' }}>
              <Typography>
                {node.health}
              </Typography>

              <FavoriteIcon htmlColor="red" fontSize='small' />
            </Box>
          </Box>

          {node.collectible && <Box sx={{ position: 'absolute', top: 3, left: 3 }}>
            <StarIcon htmlColor="gold" fontSize='small' />
          </Box>}

          {node.status === 1 && <Box sx={{ position: 'absolute', top: 30, left: 40 }}>
            <img alt='' src={skull} width={40} />
          </Box>}
        </Box>
      </LargeCustomTooltip>
    </Box>
  }

  function RenderConnectedNode(node) {
    return <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
      {RenderConnector(node, 'vertical', 0, { height: '50px' })}
      {RenderType(node, 'connected')}
    </Box>
  }

  function RenderSplitNode(node) {
    return <>
      <Box display={'flex'} alignItems={'flex-end'}>
        {RenderConnector(node, 'curved', 0, { borderLeft: '1px solid #FFF', width: '40px' })}
        {RenderType(node, 'split')}
        {RenderConnector(node, 'curved', 1, { borderRight: '1px solid #FFF', width: '39px' })}
      </Box>
    </>
  }

  function renderReversedSplitNode(node) {
    let parent1 = map.find(n => n.nodeId === node.parents[0])
    let parent2 = map.find(n => n.nodeId === node.parents[1])

    return <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
      {RenderConnector(node, 'vertical', 0, { height: '50px' })}

      <Box display={'flex'} alignItems={'flex-end'}>
        {RenderConnector(node, 'curvedReverse', parent1.status ? null : 99, { borderLeft: '1px solid #FFF', width: '40px' })}
        {RenderType(node, 'reversedSplit')}
        {RenderConnector(node, 'curvedReverse', parent2.status ? null : 99, { borderRight: '1px solid #FFF', width: '39px' })}
      </Box>
    </Box>
  }

  function RenderType(node, connector) {
    if (node.nodeType === 'monster') return RenderMonsterCircle(node);
  }

  function RenderNode(node, row, prevRow, nextRow) {
    if (prevRow && row.length < prevRow.length) {
      return RenderSplitNode(node)
    } else if (nextRow && row.length < nextRow.length) {
      return renderReversedSplitNode(node)
    } else {
      return RenderConnectedNode(node)
    }
  }

  if (tree.length === 0) {
    return <Box>Tree not generated</Box>
  }

  return (
    <>
      <Scrollbars ref={scrollbarRef}>
        <Box sx={styles.container}>
          <Box sx={styles.topNode}>
            {RenderConnectedNode(map[map.length - 1])}

            <RenderTopLine />
          </Box>

          <Box sx={{ display: 'flex', alignItems: 'center', width: '100%', justifyContent: 'center' }}>
            <Box sx={styles.section}>
              {tree.length > 1 && React.Children.toArray(
                tree[0].map((row, i) => <>
                  <Box sx={styles.row}>
                    {React.Children.toArray(
                      row.map(node => RenderNode(node, row, tree[0][i - 1], tree[0][i + 1]))
                    )}
                  </Box>
                </>)
              )}

              {tree.length === 2 && RenderConnector(map[0], 'curved', 0, { mb: 0, ml: '50%', height: '50px', borderLeft: '1px solid #FFF', width: '50%' })}
              {tree.length === 3 && RenderConnector(map[0], 'curved', 0, { mb: '60px', ml: '50%', height: '111px', borderLeft: '1px solid #FFF', width: '50%' })}
            </Box>

            {(tree.length === 1 || tree.length === 3) && <Box sx={styles.section}>
              {React.Children.toArray(
                (tree.length === 1 ? tree[0] : tree[1]).map((row, i) => <>
                  <Box sx={styles.row}>
                    {React.Children.toArray(
                      row.map(node => RenderNode(node, row, (tree.length === 1 ? tree[0] : tree[1])[i - 1], (tree.length === 1 ? tree[0] : tree[1])[i + 1]))
                    )}
                  </Box>
                </>)
              )}

              {tree.length === 3 && <Box sx={{ display: 'flex', width: '100%', justifyContent: 'center', alignItems: 'center' }}>
                {RenderConnector(map[0], 'horizontal', 0, { width: '139px', mt: '51px' })}
                {RenderConnectedNode(map[0])}
                {RenderConnector(map[0], 'horizontal', 2, { width: '139px', mt: '51px' })}
              </Box>}
            </Box>}

            <Box sx={styles.section}>
              {tree.length > 1 && React.Children.toArray(
                (tree.length > 2 ? tree[2] : tree[1]).map((row, i) => <>
                  <Box sx={styles.row}>
                    {React.Children.toArray(
                      row.map(node => RenderNode(node, row, (tree.length > 2 ? tree[2] : tree[1])[i - 1], (tree.length > 2 ? tree[2] : tree[1])[i + 1]))
                    )}
                  </Box>
                </>)
              )}

              {tree.length === 2 && RenderConnector(map[0], 'curved', 1, { mb: 0, mr: '50%', height: '50px', borderRight: '1px solid #FFF', width: '50%' })}
              {tree.length === 3 && RenderConnector(map[0], 'curved', 2, { mb: '60px', mr: '50%', height: '111px', borderRight: '1px solid #FFF', width: '50%' })}
            </Box>

          </Box>

          <Box sx={styles.topNode}>
            {tree.length < 3 && <Box sx={{ display: 'flex', width: '100%', justifyContent: 'center' }}>
              {RenderConnectedNode(map[0])}
            </Box>}

            <Box sx={{ width: '1px', height: '25px', background: '#FFE97F' }} />
          </Box>
        </Box>

      </Scrollbars>

      <RenderBattleMenu />
    </>
  )
}

export default Structure

const styles = {
  container: {
    width: '1200px',
    height: '100%',
    margin: 'auto'
  },
  section: {
    height: '100%',
    width: '400px',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'flex-end',
    boxSizing: 'border-box'
  },
  row: {
    width: '100%',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'flex-end',
    gap: '80px'
  },
  lineRow: {
    width: '100%',
    height: '30px'
  },
  circleContainer: {
    width: '120px',
    height: '120px',
    borderRadius: '100%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },
  square: {
    width: '60px',
    height: '85px',
    background: '#141920',
    border: '1px solid #ffffff3d',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'space-evenly',
    position: 'relative',
    cursor: 'pointer'
  },
  monsterCircle: {
    width: '100%',
    height: '100%',
    boxSizing: 'border-box',
    background: 'rgba(0, 0, 0, 0.6)',
    border: '1px solid #FFF',
    position: 'relative',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'space-between',
    p: 1,
    pb: '4px',
    cursor: 'pointer'
  },
  smallCircle: {
    width: '68px',
    height: '68px',
    borderRadius: '100%',
    background: 'rgba(0, 0, 0, 0.6)',
    border: '1px solid #FFF',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
    cursor: 'pointer'
  },
  curvedLine: {
    height: '109px',
    borderBottom: '1px solid #FFF',
    mb: '60px'
  },
  curvedLineReverse: {
    height: '60px',
    borderTop: '1px solid #FFF',
  },
  topNode: {
    width: '100%',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center'
  },
  cardTooltipContainer: {
    my: 0.5
  },
  tooltipContainer: {
    width: '220px',
    textAlign: 'left',
    p: 0.5
  },
  displayCard: {
    height: CardSize.big.height,
    width: CardSize.big.width,
  },
  typeContainer: {
    position: 'absolute',
    top: '5px',
    right: '5px',
  },
  battleMenu: {
    textAlign: 'left',
    p: 0.5,
    border: '1px solid rgba(255, 255, 255, 0.6)',
    background: '#141920',
  }
}
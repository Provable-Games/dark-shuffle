import { Box } from '@mui/material'
import React, { useState } from 'react'
import { LazyLoadImage } from 'react-lazy-load-image-component'
import { fetchCardList, fetch_card_image } from '../../helpers/cards'
import { _styles } from '../../helpers/styles'
import { shuffle } from '../../helpers/utilities'

function PreloadBeastImages(beasts) {
  return <>
    {React.Children.toArray(
      beasts.map(beast =>
        <LazyLoadImage
          style={{ position: 'fixed', top: '-1px', left: '-1px' }}
          alt={""}
          height={1}
          src={fetch_card_image(beast.name)}
          width={1}
        />
      ))}
  </>
}

const BANNER_COUNT = 13

function Monsters() {
  const [isLoading, setIsLoading] = useState(0);
  const [bannerBeasts] = useState([1, 2, 3, 4, 5, 7, 8, 9, 10, 12, 13])
  const [beasts] = useState(fetchCardList())

  function PreloadBannerImages() {
    return <>
      {React.Children.toArray(
        beasts.slice(0, BANNER_COUNT).map(beast =>
          <LazyLoadImage
            alt={""}
            height={1}
            src={fetch_card_image(beast.name)}
            width={1}
            onLoad={() => { setIsLoading(prev => prev + 1) }}
          />
        ))}
    </>
  }

  return (
    <Box sx={[_styles.customBox, _styles.linearBg, styles.container]} width={'100%'} height={'150px'}>
      {isLoading < BANNER_COUNT
        ? PreloadBannerImages()

        : <>
          {React.Children.toArray(
            beasts.filter(beast => bannerBeasts.includes(beast.id)).map(beast => <Box sx={{ minWidth: '120px', height: '100%', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
              <img alt='' src={fetch_card_image(beast.name)} height={'85%'} />
            </Box>)
          )}

          {PreloadBeastImages(beasts.slice(BANNER_COUNT))}
        </>}
    </Box>
  )
}

export default Monsters

const styles = {
  container: {
    overflow: 'hidden',
    display: 'flex',
    alignItems: 'center',
    gap: 6,
    px: 2,

    animationName: 'fadeInAnimation',
    animationDuration: '1s',
    animationTimingFunction: 'ease',
    animationIterationCount: '1',
    animationDirection: 'forwards',
  },
}
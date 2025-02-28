import { Box } from '@mui/material'
import React, { useState } from 'react'
import { LazyLoadImage } from 'react-lazy-load-image-component'
import { MONSTER_LIST } from '../../battle/monsterUtils'
import { fetch_card_image } from '../../helpers/cards'
import { _styles } from '../../helpers/styles'
import { useEffect } from 'react'

function preloadImages(urls) {
  urls.forEach(url => {
    const img = new Image();
    img.src = url;
  });
}

function Monsters() {
  const [isLoading, setIsLoading] = useState(0);
  const bannerBeasts = ["Warlock", "Typhon", "Jiangshi", "Anansi", "Basilisk",
    "Manticore", "Phoenix", "Dragon", "Minotaur", "Colossus", "Balrog"]

  useEffect(() => {
    const imageUrls = MONSTER_LIST().map(beast => fetch_card_image(beast.name));
    preloadImages(imageUrls);
  }, []);

  function PreloadBannerImages() {
    return <>
      {React.Children.toArray(
        bannerBeasts.map(beast =>
          <LazyLoadImage
            alt={""}
            height={1}
            src={fetch_card_image(beast)}
            width={1}
            onLoad={() => { setIsLoading(prev => prev + 1) }}
          />
        ))}
    </>
  }

  return (
    <Box sx={[_styles.customBox, _styles.linearBg, styles.container]} width={'100%'} height={'150px'}>
      {isLoading < bannerBeasts.length
        ? PreloadBannerImages()

        : <>
          {React.Children.toArray(
            bannerBeasts.map(beast => <Box sx={{ minWidth: '120px', height: '100%', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
              <img alt='' src={fetch_card_image(beast)} height={'85%'} />
            </Box>)
          )}
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
import { StyledEngineProvider, ThemeProvider } from '@mui/material/styles';
import { AnimatePresence } from "framer-motion";
import { isBrowser, isMobile } from 'react-device-detect';
import { BrowserRouter, Route, Routes, } from "react-router-dom";

import Box from '@mui/material/Box';
import { SnackbarProvider } from 'notistack';
import Header from "./components/header";
import { BattleProvider } from "./contexts/battleContext";
import { DojoProvider } from "./contexts/dojoContext";
import { DraftProvider } from "./contexts/draftContext";
import { GameProvider } from "./contexts/gameContext";
import { SeasonProvider } from "./contexts/seasonContext";
import { routes } from './helpers/routes';
import { mainTheme } from './helpers/themes';

import { useState } from 'react';
import MobileHeader from './components/mobileHeader';
import { AnimationHandler } from "./contexts/animationHandler";
import { StarknetProvider } from "./contexts/starknet";
import { ReplayProvider } from './contexts/replayContext';
import ReplayOverlay from './components/replayOverlay';

function Main() {
  const [connectWallet, showConnectWallet] = useState(false)

  return (
    <BrowserRouter>
      <Box className='bgImage'>
        <Box className='background'>
          <StyledEngineProvider injectFirst>

            <ThemeProvider theme={mainTheme}>
              <SnackbarProvider anchorOrigin={{ vertical: 'top', horizontal: 'center' }} preventDuplicate autoHideDuration={3000}>
                <AnimationHandler>

                  <StarknetProvider>
                    <DojoProvider showConnectWallet={showConnectWallet}>
                      <SeasonProvider>
                        <GameProvider>
                          <DraftProvider>
                            <BattleProvider>
                              <ReplayProvider showConnectWallet={showConnectWallet}>

                                <Box className='main'>
                                  <ReplayOverlay />
                                  {isBrowser && <Header connectWallet={connectWallet} showConnectWallet={showConnectWallet} />}
                                  {isMobile && <MobileHeader connectWallet={connectWallet} showConnectWallet={showConnectWallet} />}

                                  <AnimatePresence mode="wait">

                                    <Routes>
                                      {routes.map((route, index) => {
                                        return <Route key={index} path={route.path} element={route.content} />
                                      })}
                                    </Routes>

                                  </AnimatePresence>
                                </Box>

                              </ReplayProvider>
                            </BattleProvider>
                          </DraftProvider>
                        </GameProvider>
                      </SeasonProvider>
                    </DojoProvider>
                  </StarknetProvider>

                </AnimationHandler>
              </SnackbarProvider>
            </ThemeProvider>

          </StyledEngineProvider>
        </Box>
      </Box>
    </BrowserRouter >
  );
}

export default Main

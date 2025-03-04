import ArenaPage from "../pages/ArenaPage";
import CollectionPage from "../pages/CollectionPage";

export const routes = [
  {
    path: '/',
    content: <ArenaPage />
  },
  {
    path: '/replay/:replayGameId',
    content: <ArenaPage />
  },
  {
    path: '/spectate/:spectateGameId',
    content: <ArenaPage />
  },
  {
    path: '/library',
    content: <CollectionPage />
  },
]
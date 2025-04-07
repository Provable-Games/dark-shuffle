import ArenaPage from "../pages/ArenaPage";

export const routes = [
  {
    path: '/',
    content: <ArenaPage />
  },
  {
    path: '/watch/:watchGameId',
    content: <ArenaPage />
  },
  {
    path: '/play/:gameId',
    content: <ArenaPage />
  },
]
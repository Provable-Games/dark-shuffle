import ArenaPage from "../pages/ArenaPage";
import SettingsPage from "../pages/SettingsPage";

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
  {
    path: '/settings',
    content: <SettingsPage />
  }
]
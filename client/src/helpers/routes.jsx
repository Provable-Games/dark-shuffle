import ArenaPage from "../pages/ArenaPage";
import CollectionPage from "../pages/CollectionPage";

export const routes = [
  {
    path: '/',
    content: <ArenaPage />
  },
  {
    path: '/library',
    content: <CollectionPage />
  },
]
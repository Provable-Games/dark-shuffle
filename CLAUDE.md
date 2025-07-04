# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dark Shuffle is a deck-building game built on Starknet. It uses:
- **Frontend**: React 18 + Vite + Material-UI
- **Smart Contracts**: Cairo 2.10.1 with Dojo Engine v1.5.0
- **Blockchain**: Starknet Layer 2

## Essential Commands

### Local Development

**Start the full development environment:**
```bash
# Terminal 1: Start local blockchain (Katana)
./scripts/contracts.sh

# Terminal 2: Start indexer (Torii) - wait for Katana to be ready
./scripts/indexer.sh

# Terminal 3: Start frontend
./scripts/client.sh
```

### Frontend Commands (run from `client/` directory)
```bash
pnpm install     # Install dependencies
pnpm dev         # Start dev server (with --force flag)
pnpm build       # Production build
pnpm lint        # Run ESLint
pnpm preview     # Preview production build
```

### Smart Contract Commands (run from `contracts/` directory)
```bash
sozo build       # Build contracts
sozo test        # Run all tests
sozo migrate     # Deploy to local Katana
scarb fmt        # Format Cairo code
scarb fmt --check # Check formatting (used in CI)
```

### Testing
```bash
# Run a single contract test
sozo test -f test_function_name

# Frontend has no test command defined - check for test files before suggesting tests
```

## Architecture

### Directory Structure
- `client/` - React frontend
  - `src/api/` - Blockchain integration (indexer, starknet)
  - `src/battle/` - Battle logic and utilities
  - `src/components/` - React components
  - `src/contexts/` - State management
- `contracts/` - Cairo smart contracts
  - `src/models/` - Game data models (ECS entities)
  - `src/systems/` - Game logic (ECS systems)
  - `src/utils/` - Contract utilities
- `scripts/` - Development and deployment scripts

### Key Concepts

**Dojo Engine**: The game uses Dojo's Entity Component System (ECS) pattern:
- **Models** define game state (entities and components)
- **Systems** implement game logic that modifies state
- **World** is the deployed game instance containing all systems and models

**Game Flow**:
1. Players connect wallet via Cartridge Controller
2. Draft phase: Select cards to build a deck
3. Map navigation: Progress through game stages
4. Battle phase: Turn-based card battles with on-chain logic
5. Achievements: Track player accomplishments

### Important Files

**Entry Points**:
- `client/src/main.jsx` - Frontend entry
- `contracts/dojo_world_sepolia.toml` - Deployment config
- `contracts/src/lib.cairo` - Contract entry

**Game Logic**:
- `contracts/src/systems/draft.cairo` - Card selection
- `contracts/src/systems/battle.cairo` - Combat logic
- `contracts/src/models/game.cairo` - Core game state

**Monster Abilities**: Each creature has unique abilities in:
- `contracts/src/systems/monster_abilities/`
- `client/src/battle/creature/abilities/`

### Development Workflow

1. **Contract Changes**:
   - Modify Cairo files
   - Run `sozo build` to verify compilation
   - Run `sozo test` for affected systems
   - Run `scarb fmt` before committing

2. **Frontend Changes**:
   - GraphQL queries are generated from `client/src/queries/`
   - Card assets are in `client/src/assets/cards/`
   - Battle animations use Lottie files in `client/src/assets/animations/`

3. **Adding New Features**:
   - Define models in `contracts/src/models/`
   - Implement systems in `contracts/src/systems/`
   - Update frontend queries and components
   - Copy new manifest to client after migration

### Deployment Environments

- **Local**: Katana + Torii (development)
- **Sepolia**: Testnet deployment
- **Mainnet**: Production deployment
- **Slot**: Cartridge infrastructure deployment

Each environment has its own manifest file (`manifest_*.json`) generated after deployment.
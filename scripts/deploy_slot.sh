#!/bin/bash

cd contracts

echo "Build contracts..."
sozo -P slot build

# Delete previous deployment
# slot deployments delete darkshuffle-slot katana
# slot deployments delete darkshuffle-slot torii

# echo "Deploying world to Realms L3..."
slot deployments create darkshuffle-slot katana --version v1.0.5 --invoke-max-steps 25000000 --block-time 1000 --dev --dev.no-fee

# echo "Migrating world..."
sozo -P slot migrate

# echo "Setting up remote indexer on slot..."
# slot deployments create darkshuffle-slot torii --version v1.0.1 --world 0x043dd69c43f42ed0a62a1216e9710aaa9508d04579fd1fbec2b4530c55710e48 --rpc https://api.cartridge.gg/x/darkshuffle-slot/katana/
# cp ../contracts/manifest_slot.json ../client/manifest_slot.json

#!/bin/bash

# Navigate to the root of the repo to install dependencies
echo "Setting up Katana..."

# Change directory to contracts
cd contracts
sozo build

# Run katana with the disable-fee option
katana --invoke-max-steps 25000000 --block-time 1000 --dev --dev.no-fee
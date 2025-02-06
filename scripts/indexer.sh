#!/bin/bash

cd contracts

echo "----- Building World -----"
sozo build

echo "----- Migrating World -----"
sozo migrate

cp ../contracts/manifest_dev.json ../client/manifest_dev.json

echo "-----  Started indexer ----- "
torii --world 0x06ad3ca6a800fddf1661e986eb4d69ecb504ffb20e09e9e3bfe60b55d3946235
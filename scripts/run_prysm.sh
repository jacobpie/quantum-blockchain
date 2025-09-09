#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
PRYSM="$ROOT/clients/prysm"
mkdir -p "$ROOT/nodes/eth2" "$ROOT/nodes/validator"
"$PRYSM/beacon-chain" \
  --datadir="$ROOT/nodes/eth2" \
  --execution-endpoint="http://127.0.0.1:8551" \
  --jwt-secret="$HOME/Library/Ethereum/geth/jwtsecret" \
  --grpc-gateway-port=4000 \
  --verbosity=debug &
"$PRYSM/validator" \
  --datadir="$ROOT/nodes/validator" \
  --beacon-rpc-provider="127.0.0.1:4000" \
  --verbosity=debug &
wait

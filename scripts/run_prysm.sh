#!/usr/bin/env bash
set -euo pipefail

export PRYSM_ALLOW_UNVERIFIED_BINARIES=1

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PRYSM="$ROOT/clients/prysm"
BEACON="$PRYSM/beacon-chain"
VALIDATOR="$PRYSM/validator"
FEE_RECIPIENT="0x7599ef2683e7edf1fd55748591061e70a21a6577"

[ -x "$BEACON" ] || { echo "Missing $BEACON"; exit 1; }
[ -x "$VALIDATOR" ] || { echo "Missing $VALIDATOR"; exit 1; }

mkdir -p "$ROOT/nodes/eth2" "$ROOT/nodes/validator"

"$BEACON" \
  --accept-terms-of-use \
  --datadir="$ROOT/nodes/eth2" \
  --execution-endpoint="http://127.0.0.1:8551" \
  --jwt-secret="$HOME/Library/Ethereum/geth/jwtsecret" \
  --rpc-host=127.0.0.1 \
  --rpc-port=4000 \
  --http-host=127.0.0.1 \
  --http-port=3500 \
  --suggested-fee-recipient="$FEE_RECIPIENT" \
  --verbosity=debug &

# wait for REST health (200/206) before launching validator
for _ in $(seq 1 60); do
  code="$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:3500/eth/v1/node/health || true)"
  [ "$code" = "200" ] || [ "$code" = "206" ] && break
  sleep 1
done

"$VALIDATOR" \
  --accept-terms-of-use \
  --datadir="$ROOT/nodes/validator" \
  --wallet-dir="$ROOT/nodes/validator/wallet" \
  --wallet-password-file="$ROOT/nodes/validator/wallet.password" \
  --beacon-rpc-provider="127.0.0.1:4000" \
  --verbosity=debug &

wait

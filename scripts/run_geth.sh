#!/usr/bin/env bash
set -euo pipefail

LOGDIR="$HOME/Library/Ethereum/geth"
mkdir -p "$LOGDIR"
JWT="$LOGDIR/jwtsecret"
[ -f "$JWT" ] || openssl rand -hex 32 > "$JWT"

# stop any existing geth
pkill -INT geth 2>/dev/null || true
sleep 1

# start geth with Engine API on 8551 + RPC on 8545
nohup geth --mainnet \
  --http --http.addr 127.0.0.1 --http.port 8545 --http.api eth,net,web3 \
  --authrpc.addr 127.0.0.1 --authrpc.port 8551 \
  --authrpc.jwtsecret "$JWT" \
  --syncmode snap \
  --cache 4096 \
  --port 30303 \
  --maxpeers 50 \
  > "$LOGDIR/geth.log" 2>&1 &

echo "geth started (pid $!), log: $LOGDIR/geth.log"

# quick checks
sleep 2
echo "== geth process =="
pgrep -laf '^geth' || true
echo "== Engine API 8551 =="
lsof -nP -iTCP:8551 -sTCP:LISTEN || true

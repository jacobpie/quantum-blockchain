#!/usr/bin/env bash
set -euo pipefail

echo "== geth process =="
pgrep -laf '^geth' || echo "geth not running"

echo "== Engine API 8551 =="
lsof -nP -iTCP:8551 -sTCP:LISTEN || echo "nothing listening on 8551"

echo "== Geth syncing =="
curl -s -X POST http://127.0.0.1:8545 -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","id":1,"method":"eth_syncing","params":[]}' | python -m json.tool || true

echo "== Geth head block =="
curl -s -X POST http://127.0.0.1:8545 -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","id":2,"method":"eth_blockNumber","params":[]}' | python -m json.tool || true

echo "== Beacon health =="
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:3500/eth/v1/node/health || true

echo "== Beacon syncing =="
curl -s http://127.0.0.1:3500/eth/v1/node/syncing | python -m json.tool || true

echo "== Beacon peers =="
curl -s http://127.0.0.1:3500/eth/v1/node/peer_count | python -m json.tool || true

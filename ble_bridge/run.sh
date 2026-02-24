#!/bin/sh
set -eu

echo "[entry] starting wrapper"

OPTIONS=/data/options.json
if [ ! -f "$OPTIONS" ]; then
  echo "[entry] ERROR: $OPTIONS not found"
  exit 1
fi

# JSON mit python lesen (python ist im upstream image vorhanden)
BLE_ADDRESS="$(python -c 'import json; print(json.load(open("/data/options.json")).get("ble_address",""))')"
PORT="$(python -c 'import json; print(json.load(open("/data/options.json")).get("port",4403))')"
CACHE_NODES="$(python -c 'import json; print(str(json.load(open("/data/options.json")).get("cache_nodes",False)).lower())')"
MAX_CACHE_NODES="$(python -c 'import json; print(json.load(open("/data/options.json")).get("max_cache_nodes",500))')"
VERBOSE="$(python -c 'import json; print(str(json.load(open("/data/options.json")).get("verbose",True)).lower())')"
SCAN_ONLY="$(python -c 'import json; print(str(json.load(open("/data/options.json")).get("scan_only",False)).lower())')"

if [ "$SCAN_ONLY" = "true" ]; then
  echo "[entry] scan_only=true -> scanning..."
  exec python -m cli.main --scan
fi

if [ -z "$BLE_ADDRESS" ]; then
  echo "[entry] ERROR: ble_address is empty. Set it in the add-on config."
  echo "[entry] Tip: set scan_only=true once, read logs for the MAC, then set ble_address."
  exit 1
fi

ARGS="$BLE_ADDRESS --port $PORT --max-cache-nodes $MAX_CACHE_NODES"

if [ "$CACHE_NODES" = "true" ]; then
  ARGS="$ARGS --cache-nodes"
fi
if [ "$VERBOSE" = "true" ]; then
  ARGS="$ARGS --verbose"
fi

echo "[entry] running: python -m cli.main $ARGS"
exec sh -c "python -m cli.main $ARGS"

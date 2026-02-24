#!/usr/bin/with-contenv bashio
set -euo pipefail

BLE_ADDRESS="$(bashio::config 'ble_address')"
PORT="$(bashio::config 'port')"
CACHE_NODES="$(bashio::config 'cache_nodes')"
MAX_CACHE_NODES="$(bashio::config 'max_cache_nodes')"
VERBOSE="$(bashio::config 'verbose')"
SCAN_ONLY="$(bashio::config 'scan_only')"

ARGS=()

# scan mode
if bashio::config.true 'scan_only'; then
  echo "[ble-bridge] Scan mode enabled. Scanning for devices..."
  exec python -m cli.main --scan
fi

# validate BLE address
if [[ -z "${BLE_ADDRESS}" ]]; then
  echo "[ble-bridge] ERROR: 'ble_address' is empty. Set the MAC address (AA:BB:CC:DD:EE:FF) in the add-on configuration."
  echo "[ble-bridge] Tip: set scan_only=true once, start add-on, read logs, then set scan_only=false and paste the MAC."
  exit 1
fi

ARGS+=("${BLE_ADDRESS}")
ARGS+=(--port "${PORT}")
ARGS+=(--max-cache-nodes "${MAX_CACHE_NODES}")

if [[ "${CACHE_NODES}" == "true" ]]; then
  ARGS+=(--cache-nodes)
fi

if [[ "${VERBOSE}" == "true" ]]; then
  ARGS+=(--verbose)
fi

echo "[ble-bridge] Starting with: ${ARGS[*]}"
exec python -m cli.main "${ARGS[@]}"

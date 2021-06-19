#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Entrypoint for our snapshot Docker Compose service
#-------------------------------------------------------------------------------

# Start nodeos in background, configured to provide the producer API locally
nodeos                                                                         \
  --config-dir /config                                                         \
  --data-dir /data                                                             \
  --protocol-features-dir /protocol_features                                   \
  --http-server-address 127.0.0.1:8888                                         \
  --plugin eosio::producer_api_plugin 1>/dev/null 2>&1 &

# Wait for nodeos to get up and running
sleep 10

# Generate a snapshot
curl -X POST http://127.0.0.1:8888/v1/producer/create_snapshot | json_pp

# Instruct nodeos to shutdown normally
kill -s SIGTERM %1

# Wait for nodeos to shutdown before exiting
wait

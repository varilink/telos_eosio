#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Entrypoint for our keosd Docker Compose service
#-------------------------------------------------------------------------------

set -e

# Publish endpoint where our cleos Docker Compose service is expecting it to be
# Set --wallet-dir to the path we map the eosio_wallet volume to
exec keosd                                                                     \
  --http-server-address eosio-keosd:8888                                       \
  --wallet-dir /wallet
  "$@"

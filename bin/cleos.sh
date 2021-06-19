#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Entrypoint for our cleos Docker Compose service
#-------------------------------------------------------------------------------

set -e

# Use our keosd Docker Compose service as our wallet
exec cleos --wallet-url http://eosio-keosd:8888 "$@"

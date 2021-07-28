#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Entrypoint for our cleos Docker Compose service
#-------------------------------------------------------------------------------

set -e

defaults=""
if [[
  ! ( "$@" =~ ^"-u " || "$@" =~ " -u " ) &&
  ! ( "$@" =~ ^"--url " || "@$" =~ " --url " )
]]; then
  defaults+="--url http://eosio-nodeos:8888"
fi

# Use our keosd Docker Compose service as our wallet
exec cleos $defaults --no-auto-keosd --wallet-url http://eosio-keosd:8888 "$@"

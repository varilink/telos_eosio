#!/usr/bin/env bash

set -e

#-------------------------------------------------------------------------------
# Entrypoint for our nodeos Docker Compose service
#-------------------------------------------------------------------------------

# Set required directory locations
exec nodeos                                                                    \
  --config-dir /config                                                         \
  --data-dir /data                                                             \
  --protocol-features-dir /protocol_features                                   \
  "$@"

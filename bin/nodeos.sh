#!/usr/bin/env bash

set -e

#-------------------------------------------------------------------------------
# Entrypoint for our nodeos Docker Compose service
#-------------------------------------------------------------------------------

if [[
  "$@" == "-h" || "$@" == "--help" ||
  "$@" == "-v" || "$@" == "--version" ||
  "$@" == "--full-version" ||
  "$@" == "--print-default-config"
]]; then

  exec nodeos "$@"

else

  defaults=""

  if [[
    ! ( "$@" =~ ^"--config-dir " || "$@" =~ " --config-dir " )
  ]]; then
    defaults+="--config-dir=/config "
  fi

  if [[
    ! ( "$@" =~ ^"-d " || "$@" =~ " -d " ) &&
    ! ( "$@" =~ ^"--data-dir " || "@$" =~ " --data-dir " )
  ]]; then
    defaults+="--data-dir=/data "
  fi

  if [[ ! (
    "$@" =~ ^"--protocol-features-dir " ||
    "$@" =~ " --protocol-features-dir "
  ) ]]; then
    defaults+="--protocol-features-dir=/protocol_features "
  fi

  exec nodeos $defaults "$@"

fi

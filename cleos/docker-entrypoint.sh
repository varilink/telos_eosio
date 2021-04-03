#!/usr/bin/env bash

set -e

exec cleos --wallet-url http://varilink-keosd:8888 "$@"

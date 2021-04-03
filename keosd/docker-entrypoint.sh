#!/usr/bin/env bash

set -e

exec keosd --http-server-address varilink-keosd:8888 "$@"

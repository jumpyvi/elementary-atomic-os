#!/bin/bash

set -e

if [[ "$(id -u)" != 0 ]]; then
  echo "E: Requires root permissions" > /dev/stderr
  exit 1
fi

mkosi -B --debug --force --profile=sysupdate

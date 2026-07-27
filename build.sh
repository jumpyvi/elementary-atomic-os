#!/bin/bash

set -e

mkosi --version
mkosi genkey || true
mkosi -B --debug --force --profile=sysupdate

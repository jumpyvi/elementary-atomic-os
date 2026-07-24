#!/bin/bash

set -e

KEY="$1"
SECRET="$2"
ENDPOINT="$3"
BUCKET="$4"

echo -e "
#----------------------#
# INSTALL DEPENDENCIES #
#----------------------#
"

apt-get update
apt-get install -y python3 python3-boto3

echo -e "
#------------#
# UPLOAD RAW #
#------------#
"

RAWPATHS="$(find mkosi.output -name "*.raw" ! -name "*.esp.raw")"
while IFS= read -r RAWPATH; do
  SHAPATH="${RAWPATH}.sha256"
  MD5PATH="${RAWPATH}.md5"

  sha256sum "$RAWPATH" | tee "$SHAPATH"
  md5sum "$RAWPATH" | tee "$MD5PATH"

  REMOTE="$(basename "$RAWPATH")"
  echo "uploading $REMOTE..."
  python3 upload.py "$KEY" "$SECRET" "$ENDPOINT" "$BUCKET" "$RAWPATH" "$REMOTE" || exit 1
  echo "uploading $REMOTE.sha256..."
  python3 upload.py "$KEY" "$SECRET" "$ENDPOINT" "$BUCKET" "$SHAPATH" "$REMOTE.sha256" || exit 1
  echo "uploading $REMOTE.md5..."
  python3 upload.py "$KEY" "$SECRET" "$ENDPOINT" "$BUCKET" "$MD5PATH" "$REMOTE.md5" || exit 1
done <<< "$RAWPATHS"

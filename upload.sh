#!/bin/bash

set -e

KEY="$1"
SECRET="$2"
ENDPOINT="$3"
UPDATES_BUCKET="$4"
INSTALL_BUCKET="$5"

upload_file() {
  local bucket="$1"
  local src="$2"
  local dst="$3"
  python3 upload.py "$KEY" "$SECRET" "$ENDPOINT" "$bucket" "$src" "$dst" || exit 1
}

echo -e "
#----------------------#
# INSTALL DEPENDENCIES #
#----------------------#
"

apt-get update
apt-get install -y python3 python3-boto3

echo -e "
#---------------------------------#
# UPLOAD TO SYSUPDATES CLOUDFLARE #
#---------------------------------#
"

ALLFILES="$(find mkosi.output -type f)"
while IFS= read -r FILE; do
  REMOTE="$(basename "$FILE")"
  echo "uploading $REMOTE to $UPDATES_BUCKET..."
  upload_file "$UPDATES_BUCKET" "$FILE" "$REMOTE"
done <<< "$ALLFILES"

echo -e "
#-----------------------------------#
# UPLOAD NSTALLER-ISO TO CLOUDFLARE #
#-----------------------------------#
"

RAW="mkosi.output/Elementary_x86-64.raw"
SHA="${RAW}.sha256"
MD5="${RAW}.md5"

sha256sum "$RAW" | tee "$SHA"
md5sum "$RAW" | tee "$MD5"

upload_file "$INSTALL_BUCKET" "$RAW" "elementaryos.raw"
upload_file "$INSTALL_BUCKET" "$SHA" "elementaryos.raw.sha256"
upload_file "$INSTALL_BUCKET" "$MD5" "elementaryos.raw.md5"

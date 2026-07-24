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

UPDATE_FILES="$(find mkosi.output -type f \( -name '*.efi' -o -name '*.manifest' -o -name '*.usr-*' -o -name 'SHA256SUMS' \))"
while IFS= read -r FILE; do
  REMOTE="$(basename "$FILE")"
  echo "uploading $REMOTE to $UPDATES_BUCKET..."
  upload_file "$UPDATES_BUCKET" "$FILE" "$REMOTE"
done <<< "$UPDATE_FILES"

echo -e "
#-----------------------------------#
# UPLOAD INSTALLER-ISO TO CLOUDFLARE #
#-----------------------------------#
"

RAW="$(ls mkosi.output/Elementary_*_x86-64.raw)"
SHA="${RAW}.sha256"
MD5="${RAW}.md5"

sha256sum \
  mkosi.output/Elementary_*_x86-64.usr-x86-64-verity-sig.*.raw \
  mkosi.output/Elementary_*_x86-64.usr-x86-64-verity.*.raw \
  mkosi.output/Elementary_*_x86-64.usr-x86-64.*.raw \
  mkosi.output/Elementary_*_x86-64.efi \
  > SHA256SUMS

sha256sum "$RAW" | tee "$SHA"
md5sum "$RAW" | tee "$MD5"

upload_file "$INSTALL_BUCKET" "$RAW" "elementaryos.raw"
upload_file "$INSTALL_BUCKET" "$SHA" "elementaryos.raw.sha256"
upload_file "$INSTALL_BUCKET" "$MD5" "elementaryos.raw.md5"

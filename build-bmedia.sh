#!/bin/bash

set -e

echo "Building sysupdate profile to extract UKI..."
# just run-in-podman mkosi -B --debug --force --profile=sysupdate


RAW_IMAGE=$(find mkosi.output -maxdepth 1 -type f \
    | grep -E '/[^/]+_[0-9]{14}\.raw$' \
    | head -n1)

if [ -z "$RAW_IMAGE" ]; then
    echo "Fatal Error: no timestamped .raw image found in mkosi.output" >&2
    exit 1
fi

chown -R "$USER":"$USER" mkosi.output

echo "Building final live ISO..."

BASE_ISO="base.iso"
OUT_ISO="mkosi.output/elementary-liveiso.iso"
INSTALL_SCRIPT="mkosi.profiles/liveiso/mkosi.extra/usr/sbin/elementary-install"
REPART_DIR="mkosi.profiles/liveiso/mkosi.extra/etc/repart-installer"

rm -f "$OUT_ISO"

podman run --rm \
  -v "$PWD:/work:Z" \
  -w /work \
  docker.io/alpine:latest \
  sh -c '
    apk add --no-cache xorriso && \
    xorriso -indev "'"$BASE_ISO"'" \
      -outdev "'"$OUT_ISO"'" \
      -boot_image any replay \
      -map "'"$RAW_IMAGE"'" "/extra/'"$(basename "$RAW_IMAGE")"'" \
      -map "'"$INSTALL_SCRIPT"'" "/extra/install.sh" \
      -map "'"$REPART_DIR"'" "/extra/repart.d" \
      -chmod 0755 "/extra/install.sh" -- \
      -commit
  '

chmod 666 "$OUT_ISO"

echo "Done: $OUT_ISO"
#!/bin/bash

set -e

echo "Building sysupdate profile to extract UKI..."

rm -f ./mkosi.profiles/liveiso/mkosi.extra/usr/lib/elementary-install/Elementary_*.efi

just run-in-podman mkosi -B --debug --force --profile=sysupdate

SYSUPDATE_UKI=$(ls mkosi.output/*.efi | head -n 1)

if [ -z "$SYSUPDATE_UKI" ]; then
    echo "Error: sysupdate UKI"
    exit 1
fi

echo "Found sysupdate UKI: $SYSUPDATE_UKI"
mkdir -p mkosi.profiles/liveiso/mkosi.extra/usr/lib/elementary-install
cp "$SYSUPDATE_UKI" mkosi.profiles/liveiso/mkosi.extra/usr/lib/elementary-install/

echo "Building liveiso profile..."
just run-in-podman mkosi -B --debug --force --profile=liveiso



RAW_IMAGE=$(find mkosi.output -maxdepth 1 -type f \
    | grep -E '/[^/]+_[0-9]{14}\.raw$' \
    | head -n1)

if [ -n "$RAW_IMAGE" ]; then
    ISO_IMAGE="${RAW_IMAGE%.raw}.iso"
    cp "$RAW_IMAGE" "$ISO_IMAGE"
    echo "Converting $RAW_IMAGE to ISO: $ISO_IMAGE"
    
    systemd-repart \
        --no-pager \
        --dry-run=no \
        --size=6.7G \
        --empty=allow \
        --definitions=./mkosi.profiles/liveiso/mkosi.repart \
        --el-torito=true \
        --private-key=./mkosi.key \
        --certificate=./mkosi.crt \
        --el-torito-volume="Elementary-root" \
        --el-torito-publisher="Elementary" \
        "$ISO_IMAGE"
fi
chown -R $USER:$USER mkosi.output


echo "Build complete"
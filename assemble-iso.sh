#!/usr/bin/env bash
set -euo pipefail
cd mkosi.output/live/

SEARCH_DIR=../sysupdate

SEARCH_DIR=../sysupdate
OUT_ISO="./elementary-liveiso.iso"

for arg in "$@"; do
    if [ "$arg" = "--classic" ]; then
        SEARCH_DIR=../classic
        OUT_ISO="./elementary-liveiso_classic.iso"
    fi
done

RAW_IMAGE=$(find "$SEARCH_DIR" -maxdepth 1 -type f \
    | grep -E '/[^/]+_[0-9]{14}\.raw$' \
    | head -n1)

if [[ -z "$RAW_IMAGE" ]]; then
    echo "error: No .raw image found matching the pattern." >&2
    exit 1
fi

XZ_IMAGE="${RAW_IMAGE}.xz"
echo "Compressing raw image: $RAW_IMAGE -> $XZ_IMAGE..."
xz -7 -T0 -c "$RAW_IMAGE" > "$XZ_IMAGE"

# Detect version
output_dir=$(ls -d ElementaryLive_* | grep -vE '\.(raw|iso|vmlinuz|initrd|efi|manifest)$' | head -n 1)

if [[ -z "$output_dir" ]]; then
    echo "error: No mkosi.output, run just build-flash first." >&2
    exit 1
fi

base_name=$(basename "$output_dir")
echo "Detected release target: $base_name"

rm -rf iso_root
mkdir -p iso_root/casper
mkdir -p iso_root/boot/grub

# Write the GRUB configuration for Casper
cat << 'EOF' > iso_root/boot/grub/grub.cfg
set timeout=0
set default=0

menuentry "ElementaryOS9 Live (pre-alpha)" {
    linux /casper/vmlinuz boot=casper quiet splash ---
    initrd /casper/initrd
}
EOF

echo "Shoving everything in casper..."
sudo podman run --rm -it \
  --network host \
  --dns 8.8.8.8 \
  -v "$(pwd)":/workspace \
  -w /workspace \
  alpine:latest \
  sh -c "set -e && \
           apk update && \
           apk add --no-cache squashfs-tools grub grub-efi mtools xorriso && \
           
           KERNEL_VERSION=\$(ls ${base_name}/lib/modules | head -n 1) && \
           chroot ${base_name} update-initramfs -u -k \${KERNEL_VERSION} && \
           
           cp ${base_name}/boot/vmlinuz-\${KERNEL_VERSION} iso_root/casper/vmlinuz && \
           cp ${base_name}/boot/initrd.img-\${KERNEL_VERSION} iso_root/casper/initrd && \
           
           rm -f iso_root/casper/filesystem.squashfs && \
           mksquashfs ${base_name} iso_root/casper/filesystem.squashfs -comp xz && \
           
           grub-mkrescue -o custom_ubuntu_live.iso iso_root/ && \
           echo 'Live environment generated!'"


echo "Generating installer..."
BASE_ISO="./live/custom_ubuntu_live.iso"
rm -f "../$OUT_ISO"

cp "$XZ_IMAGE" .
LOCAL_RAW_IMAGE="./live/$(basename "$XZ_IMAGE")"

podman run --rm \
  -v "../:/work:Z" \
  -w /work \
  docker.io/alpine:latest \
  sh -c '
    apk add --no-cache xorriso && \
    xorriso -indev "'"$BASE_ISO"'" \
      -outdev "'"$OUT_ISO"'" \
      -boot_image any keep \
      -map "'"$LOCAL_RAW_IMAGE"'" /extra/"$(basename "'"$LOCAL_RAW_IMAGE"'")" \
      -commit
  '

rm -f "$(basename "$XZ_IMAGE")"

echo "Success! Your live ISO is at: mkosi.output/elementary-liveiso.iso"
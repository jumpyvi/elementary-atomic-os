#!/usr/bin/env bash
set -euo pipefail
cd mkosi.output/


# Detect version
output_dir=$(ls -d Elementary_* | grep -vE '\.(raw|iso|vmlinuz|initrd|efi|manifest)$' | head -n 1)

if [[ -z "$output_dir" ]]; then
    echo "error: No mkosi.output, run just build-flash first." >&2
    exit 1
fi

base_name=$(basename "$output_dir")
echo "Detected release target: $base_name"

rm -rf iso_root
mkdir -p iso_root/casper
mkdir -p iso_root/boot/grub

# Write the GRUB configuration for Casper, it doesnt work in mkosi.extra/boot for some reason
cat << 'EOF' > iso_root/boot/grub/grub.cfg
set timeout=5
set default=0

menuentry "ElementaryOS9 Live (pre-alpha)" {
    linux /casper/vmlinuz boot=casper quiet splash ---
    initrd /casper/initrd
}
EOF

echo "Shove everything in casper..."
sudo podman run --rm -it \
  -v "$(pwd)":/workspace \
  -w /workspace \
  ubuntu:24.04 \
  bash -c "set -e && \
           apt-get update && \
           DEBIAN_FRONTEND=noninteractive apt-get install -y squashfs-tools grub-pc-bin grub-efi-amd64-bin mtools xorriso initramfs-tools && \
           
           KERNEL_VERSION=\$(ls ${base_name}/lib/modules | head -n 1) && \
           chroot ${base_name} update-initramfs -u -k \${KERNEL_VERSION} && \
           
           cp ${base_name}/boot/vmlinuz-\${KERNEL_VERSION} iso_root/casper/vmlinuz && \
           cp ${base_name}/boot/initrd.img-\${KERNEL_VERSION} iso_root/casper/initrd && \
           
           rm -f iso_root/casper/filesystem.squashfs && \
           mksquashfs ${base_name} iso_root/casper/filesystem.squashfs -comp xz && \
           
           grub-mkrescue -o custom_ubuntu_live.iso iso_root/ && \
           echo 'Build complete!'"

echo "Success! Your live ISO is at: mkosi.output/custom_ubuntu_live.iso"
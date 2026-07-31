# resize:
#     qemu-img resize ./mkosi.output/Elementary_x86-64.raw +40G


default:
    #!/usr/bin/env bash
    set -xeuo pipefail
    just build-sysupdate

build-sysupdate:
    rm -rf mkosi.output/ && \
    sudo $(which mkosi) -B --debug --force --profile=elementaryos --profile=sysexts --workspace-directory=$HOME/.cache/mkosi-workspace && \
    sudo chown -R $(whoami):$(whoami) ./mkosi.output/

build-iso:
    rm -rf mkosi.output/ && \
    sudo $(which mkosi) -B --debug --force --profile=liveiso --workspace-directory=$HOME/.cache/mkosi-workspace && \
    sudo chown -R $(whoami):$(whoami) ./mkosi.output/


flash:
    #!/bin/bash
    read -p "Enter .raw image path: " raw_img
    read -p "Enter destination (/dev/sdX): " dest_dev

    sudo systemd-repart --copy-from "$raw_img" --definitions=./mkosi.profiles/liveiso/mkosi.extra/etc/repart-config/ --dry-run=no --empty=force "$dest_dev"

clean:
    mkosi clean
    sudo rm -r mkosi.tools/ mkosi.cache/

sign-repo:
    #!/usr/bin/env bash
    cd mkosi.output
    echo "Repo will not be signed, use verify=no."
    echo "Generating SHA256..."
    sha256sum Elementary_*.usr-x86-64-verity-sig.*.raw \
          Elementary_*.usr-x86-64-verity.*.raw \
          Elementary_*.usr-x86-64.*.raw \
          Elementary_*.efi \
          > SHA256SUMS
    cd ..
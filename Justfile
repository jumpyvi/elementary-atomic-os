default:
    #!/usr/bin/env bash
    set -xeuo pipefail
    just --choose

do-daily:
    #!/usr/bin/env bash
    sudo rm -rf mkosi.output/ && \
    just run-in-podman mkosi -B --debug --profile=daily --force --workspace-directory=/workspace && \
    sudo ./assemble-iso.sh


do-release:
    #!/usr/bin/env bash
    echo "nyi, run do-daily instead"

genkey:
    just run-in-podman mkosi genkey

run-in-podman +command:
    mkdir -p {{env_var('HOME')}}/.cache/mkosi-workspace
    sudo mkdir -p /var/cache/mkosi
    
    sudo podman run --rm -it \
        --network host \
        --dns 8.8.8.8 \
        --privileged \
        --security-opt label=disable \
        -v /var/cache/mkosi:/var/cache/mkosi \
        -v /dev:/dev \
        -v "{{invocation_directory()}}:/work" \
        -w /work \
        -v "{{env_var('HOME')}}/.cache/mkosi-workspace:/workspace" \
        ghcr.io/jumpyvi/mkosi:tanit \
        {{command}}



clean:
    just run-in-podman mkosi clean
    sudo rm -r mkosi.tools/ mkosi.cache/ /var/cache/mkosi/*

checksum-repo:
    #!/usr/bin/env bash
    cd mkosi.output
    sha256sum elementary_*.efi \
        elementary_*.usr-*.*.raw.zst \
        elementary_*.usr-*-verity.*.raw.zst \
        elementary_*.usr-*-verity-sig.*.raw.zst \
        > SHA256SUMS
    cat SHA256SUMS

checksum-ext:
    #!/usr/bin/env bash
    cd mkosi.output
    mkdir -p ext
    mv ext-*.raw.zst ext/
    mv ext-*.addon.efi ext/
    cd ext/
    sha256sum ext-*.raw.zst > SHA256SUMS
    sha256sum ext-*.addon.efi >> SHA256SUMS
    cat SHA256SUMS

serve:
    #!/usr/bin/env bash
    cd mkosi.output
    echo "Sysupdate accessible in Gnome Boxes at http://10.0.2.2:7070"
    echo "Extensions accessible in Gnome Boxes at http://10.0.2.2:7070/ext/"
    python -m http.server 7070
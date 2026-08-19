default:
    #!/usr/bin/env bash
    set -xeuo pipefail
    just --choose

do-daily:
    #!/usr/bin/env bash
    sudo rm -rf mkosi.output/
    just run-in-podman mkosi -B --debug --profile=daily --force --workspace-directory=/workspace
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

sign-repo:
    #!/usr/bin/env bash
    cd mkosi.output
    echo "Repo will not be signed, use verify=no."
    echo "Generating SHA256..."
    sha256sum elementary_*.usr-x86-64-verity-sig.*.raw \
          elementary_*.usr-x86-64-verity.*.raw \
          elementary_*.usr-x86-64.*.raw \
          elementary_*.efi \
          > SHA256SUMS
    cd ..
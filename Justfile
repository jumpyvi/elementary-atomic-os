default:
    #!/usr/bin/env bash
    set -xeuo pipefail
    just --choose

profile-sysupdate:
    sudo rm -rf mkosi.output/sysupdate
    just run-in-podman mkosi -B --debug --force --profile=sysupdate --workspace-directory=/workspace
    sudo chown -R {{env_var('USER')}}:{{env_var('USER')}} ./mkosi.output/

build-classic-liveenv:
    sudo rm -rf mkosi.output/classic
    just run-in-podman mkosi -B --debug --force --profile=classic --workspace-directory=/workspace
    sudo chown -R {{env_var('USER')}}:{{env_var('USER')}} ./mkosi.output/

generate-liveiso:
    #!/usr/bin/env bash
    # just profile-sysupdate && \
    just build-classic-liveenv && \
    ./assemble-iso.sh


genkey:
    just run-in-podman mkosi genkey

run-in-podman +command:
    mkdir -p {{env_var('HOME')}}/.cache/mkosi-workspace
    
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
        ghcr.io/jumpyvi/mkosi-debian:26 \
        {{command}}



clean:
    just run-in-podman mkosi clean
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
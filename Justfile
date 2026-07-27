# resize:
#     qemu-img resize ./mkosi.output/Elementary_x86-64.raw +40G

alias serve := start-sysupdate-server

default:
    #!/usr/bin/env bash
    set -xeuo pipefail
    just build-sysupdate

lazy-spin:
    just _gen_keys
    just build-sysupdate

build-sysupdate:
    rm -rf mkosi.output/ && \
    sudo $(which mkosi) -B --debug --force --profile=elementaryos --profile=sysexts --workspace-directory=$HOME/.cache/mkosi-workspace && \
    sudo chown -R $(whoami):$(whoami) ./mkosi.output/

_gen_keys:
    mkosi genkey || true


clean:
    mkosi clean
    sudo rm -r mkosi.tools/ mkosi.cache/

start-sysupdate-server:
    #!/usr/bin/env bash
    mkdir -p mkosi.output/se/ && \
    just sign-ext && \
    just sign-repo && \
    python -m http.server -d mkosi.output 7676


sign-ext:
    #!/usr/bin/env bash
    cd mkosi.output/se/
    echo "Sysexts will not be signed, use verify=no."
    echo "Generating SHA256..."
    sha256sum *.raw > SHA256SUMS
    cd ../../

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
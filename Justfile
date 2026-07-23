alias serve := start-sysupdate-server

default:
    #!/usr/bin/env bash
    set -xeuo pipefail
    just build-sysupdate

lazy-spin:
    just _gen_keys
    just build-sysupdate && just resize

build-sysupdate:
    mkosi -B --debug --force --profile=sysupdate && \
    just sign-repo

resize:
    qemu-img resize ./mkosi.output/Elementary_x86-64.raw +40G

_gen_keys:
    mkosi genkey || true


clean:
    mkosi clean
    sudo rm -r mkosi.tools/ mkosi.cache/

start-sysupdate-server:
    python -m http.server -d mkosi.output 7676

sign-repo:
    #!/usr/bin/env bash
    set -euo pipefail
    export GNUPGHOME="$(mktemp -d)"
    trap 'rm -rf "$GNUPGHOME"' EXIT

    gpg --batch --generate-key <<EOF
    %no-protection
    Key-Type: eddsa
    Key-Curve: ed25519
    Key-Usage: sign
    Name-Real: ephemeral
    Expire-Date: 0
    %commit
    EOF

    cd mkosi.output
    sha256sum Elementary_x86-64.usr-x86-64.* Elementary_x86-64.efi > SHA256SUMS
    gpg --batch --yes --local-user sysupdate-dev --detach-sign --armor -o SHA256SUMS.gpg SHA256SUMS
    gpg --export sysupdate-dev > sysupdate-dev.pgp
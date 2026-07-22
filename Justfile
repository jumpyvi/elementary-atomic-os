default:
    #!/usr/bin/env bash
    set -xeuo pipefail
    just build-sysupdate

lazy-spin:
    just _gen_keys
    just build-sysupdate && just resize

build-sysupdate:
    mkosi -B --debug --force --profile=sysupdate

resize:
    qemu-img resize ./mkosi.output/Elementary_x86-64.raw +40G

_gen_keys:
    mkosi genkey || true


clean:
    mkosi clean
    sudo rm -r mkosi.tools/ mkosi.cache/

<div align="center">
  <a href="https://elementary.io" align="center">
    <center align="center">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/elementary/brand/main/logomark-white.png">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/elementary/brand/main/logomark-black.png">
  <img src="https://raw.githubusercontent.com/elementary/brand/main/logomark-black.png" alt="elementary" align="center" height="200">
</picture>
    </center>
  </a>
  <br>
  <h1 align="center"><center>elementary OS</center></h1>
  <h3 align="center"><center>Build scripts for image creation</center></h3>
  <br>
  <br>
</div>

<p align="center">
  <img src="https://github.com/elementary/os/actions/workflows/stable-8.1.yml/badge.svg" alt="Stable 8.1">
  <img src="https://github.com/elementary/os/actions/workflows/daily-8.1.yml/badge.svg" alt="Daily 8.1">
</p>

---

## Building Locally

1. Install `mkosi`, `just`, `fzf`
2. Generate keys `just _gen_keys`
3. Build `just build-sysupdate`
4. Resize `just resize`

### Run with qemu

You can directly boot the .raw image with qemu, make sure to have TPM and UEFI enabled


### Run on baremetal

`sudo dd if=mkosi.output/Elementary---.raw of=/dev/sdX bs=4M status=progress`

## Further Information

More information about the concepts behind `live-build` and the technical decisions made to arrive at this set of tools to build an .iso can be found [on the wiki](https://github.com/elementary/os/wiki/Building-iso-Images).

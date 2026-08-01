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
  <img src="https://github.com/jumpyvi/elementary-atomic-os/actions/workflows/release.yaml/badge.svg" alt="Monthly 9.0">
</p>

---

## Building ISO Locally

1. Install `podman`
2. Generate keys `just genkey`
3. Build `just build-iso`
4. `qemu-img resize mkosi.output/Elementary....raw 6G`


### Install (qemu)

1. Add the iso as a disk
2. Add a destination disk (Minimum tested is 70gb)
3. Boot the liveiso
4. Run `sudo elementary-install`

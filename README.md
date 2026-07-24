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

### Run with qemu

- Resize with `qemu-img resize "$(ls mkosi.output/Elementary_*_x86-64.raw)" +40G`, and you can then directly boot the .raw image with qemu or VirtManager/libvirt. 
- Make sure to have TPM and UEFI enabled in libvirt (Gnome Boxes won't work - doesn't support TPM).


### Install / run on baremetal

Copy the main .raw file to a 40+ GB USB stick with one of the options below. It will then expand and be bootable. Note: Don't run this after resizing for qemu or your image will be the wrong shape.

`sudo dd if=mkosi.output/Elementary_20260724221929_x86-64.raw of=/dev/sdX bs=4M status=progress` where X is your usb drive on /dev/sda, etc

or

`sudo mkosi burn /dev/sdX` where X is your usb drive on /dev/sda, etc

or 

Fedora Media Writer, etc.

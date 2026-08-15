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

## Building, Testing, and Installation

You'll need the following dependencies:
* podman
* just

Create the cache directory
```
sudo mkdir /var/cache/mkosi
```

Generate keys and then build with `just`

```bash
just genkey
just generate-liveiso
```
Create install media with [Fedora Media Writer](https://flathub.org/en/apps/org.fedoraproject.MediaWriter) or [Impression](flathub.org/en/apps/io.gitlab.adhami3310.Impression). Or boot with Gnome Boxes (>=51). Then, in demo mode, install via script:

```bash
run0 elementary-install
```

It should take arround a minute, then reboot. After boot, Flatpak should start installing, it might take a while.

## Operations

### Upgrades

`run0 sysupdate update --verify=no`

Append the exact version ID at the end to upgrade to a specific version, or downgrade.

## Minimum specs
- UEFI
- ~8gb usb stick
- Gnome Boxes >=51 (for VM only)
- 70gb destination disk, 4gb ram (less should be possible, but not tested)


### Versions

| Features        | elementary OS 9                    | elementary OS 9 "Classic" |
| --------------- | ---------------------------------- | ------------------------- |
| -> **Bootloader**      | systemd-boot (UEFI-Only)           | grub2                     |
| -> **Atomic**          | Readonly /usr, with verity and sig | Insecure/Legacy           |
| -> **Upgrade method**  | systemd-sysupdate, monthly                  | Manual, with apt-get      |
| -> **Nvidia**          | Nvidia-Open available              | Manual, with apt-get      |
| -> **Encryption**      | TPM, Passphrase or none            | TPM, Passphrase or none   |
| -> **Packages** | Flatpak, Linuxbrew and Sysupdate   | Flatpak and apt-get       |
| -> **Kernel**          | Latest Ubuntu, UKI                 | Latest Ubuntu, UKI        |
| -> **Display**       | Wayland                            | X11 or Wayland                    |
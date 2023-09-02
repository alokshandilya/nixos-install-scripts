# Nix OS Installation Cheatsheet

My personal cheatsheet for Nix OS Installation.

- download latest ISO and verify checksums
  - [**Download Nix OS (_I prefer Minimal ISO_)**](https://nixos.org/download)
- scripts to install, _snapper setup_
  - [**Install Scripts**](https://github.com/alokshandilya/nixos-install-scripts.git)

## Boot to ISO and check Networking

I usually set bigger font with `setfont ter-v32n` :

- `sudo -i` _(can use `nixos-help` for manual)_
- [ ] TODO!! update for networking

> connecting with Ethernet or mobile USB tethering is enabled by **_default_**

## Partition the disk(s)

I install Nix on my ~233G SSD.

- i prefer `gdisk`
- `ef00` for fat32 fstype

| _nvme0n1_ | _fstype_ | _size_ | _mount point_                                                  | _Label_ |
| --------- | -------- | ------ | -------------------------------------------------------------- | ------- |
| nvme0n1p1 | fat32    | 550M   | /boot/efi                                                      | EFI     |
| nvme0n1p2 | btrfs    | 232G   | /<br>/home<br>/var/log<br>/.snapshots<br>/var/cache/pacman/pkg | BTRFS   |

- `nvme0n1p2` remaining size. **_~232G_**
  > later set up `zram`

## Format and Mount the partitions

install _git_, _neovim_

```sh
nix-env -f '<nixpkgs>' -iA neovim
nix-env -f '<nixpkgs>' -iA git
```

```sh
git clone https://github.com/alokshandilya/nixos-install-scripts.git
```

all scripts are executable but still have a glance on the commands and **modify** accordingly

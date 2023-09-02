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

```sh
./1-format_mount.sh
```

- run 🏃`./1-format_mount.sh`
  - formats the partitions
  - makes btrfs subvolumes
  - mounts the partitions
  - generates fstab based on UUIDs _(remove subvolid later from `/etc/fstab`)_

## Install NIX-OS

- `nixos-generate-config --root /mnt`
- `nvim /mnt/etc/nixos/configuration.nix`, manually add mount options
- `nixos-install`

- `nixos-generate-config --show-hardware-config` doesn't detect mount options automatically, so to enable compression, you must specify it and
other mount options in a persistent configuration:

```sh
fileSystems = {
  "/".options = [ "defaults,noatime,compress=zstd,discard=async,space_cache=v2,autodefrag" ];
  "/home".options = [ "defaults,noatime,compress=zstd,discard=async,space_cache=v2,autodefrag" ];
  "/nix".options = [ "defaults,noatime,compress=zstd,discard=async,space_cache=v2,autodefrag" ];
  "/.snapshots".options = [ "defaults,noatime,compress=zstd,discard=async,space_cache=v2,autodefrag" ];
};

```
- TODO!!! update it with your nix configuration file
- update the configuration file
-  If you want to use GRUB, set boot.loader.grub.device to nodev and boot.loader.grub.efiSupport to true.
With systemd-boot, you should not need any special configuration to detect other installed systems. With GRUB, set boot.loader.grub.useOSProber to true, but this will only detect windows partitions, not other Linux distributions. If you dual boot another Linux distribution, use systemd-boot instead. 

# TODO!!! later

```sh
./2-base-install.sh
```

- edit `/etc/default/grub`
  - `blkid > blkit.txt` _:vs_ _:bp_ _:bn_ in vim `/etc/default/grub`
    - note `nvme0n1p2` _(partition with subvolumes)_ UUID
  - `GRUB_CMDLINE_LINUX=cryptdevice=UUID=xxxxx:cryptroot rootfstype=btrfs`
  - `grub-mkconfig -o /boot/grub/grub.cfg`

> run 🏃 `3-touchpad.sh` if to use Window Manager (on laptop) to enable trackpad reverse scrolling etc.

- edit `/etc/mkinitcpio.conf`
  - `MODULES=(btrfs crc32c-intel intel_agp i915 nvidia)`
  - `HOOKS=(.... encrypt filesystems fsck)`
- `mkinitcpio -P`
- do `exit` , `umount -a` , `reboot`

## Post Installation

- connect to wifi with `nmtui`

### Install DWM :robot:

```sh
./4-dwm-install.sh
```

- reboot
- run 🏃`5-packages-AUR.sh`
  - AURs are commented
- install rest of the packages

```sh
cd ~/arch-install-scripts
paru -S stow
paru -S --needed - < pkglist.txt
```

#### Dotfiles :star2:

- `4-dwm-install` script also installs paru

```sh
git clone https://github.com/alokshandilya/dotfiles.git
git clone https://github.com/alokshandilya/nvim.git ~/.config/nvim
cd dotfiles
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/bin/scripts
mkdir -p ~/.local/bin/dwmblocks
stow .
```

### Reduce Swappiness

```sh
su -
touch /etc/sysctl.d/99-swappiness.conf
echo "vm.swappiness=1" >> /etc/sysctl.d/99-swappiness.conf
```

- reboot

## Development Environment :computer:

- [ ] fish
- [ ] fnm
  - `fnm ls-remote`
  - install node, npm

```sh
npm i -g prettier typescript typescript-language-server live-server
```

- [ ] git

```sh
git config --global core.editor nvim
git config --global user.name "your_name"
git config --global user.email "your_email@example.com"
ssh-keygen -t ed25519 -C "your_email@example.com"
```

```sh
bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
exit
```

```sh
cat ~/.ssh/id_ed25519.pub
# Then select and copy the contents of the id_ed25519.pub file
# displayed in the terminal to your clipboard
```

> Github $\to$ SSH and GPG keys $\to$ Add new $\to$ Title **(Personal Arch Linux)** $\to$ Key (paste)

- [x] setup `nvim`
  - `v` alias for [nvim](https://github.com/alokshandilya/nvim.git)

- [x] setup `sdkman` for fish

```sh
curl -s "https://get.sdkman.io" | bash
# path already set in my fish config
# install omf
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
omf install sdk
sdk ls java
sdk install java #version
```

- [x] nvim `jdtls` from `:LspInstallInfo`

```sh
pip install pynvim
git clone git@github.com:alokshandilya/nvim.git ~/.config/nvim
mkdir -p ~/.local/share/fonts/nvim-fonts
cp -r ~/.config/nvim/fonts ~/.local/share/fonts/nvim-fonts
paru -S --needed google-java-format
git clone git@github.com:microsoft/java-debug.git ~/.config/nvim/java-debug
cd ~/.config/nvim/java-debug
./mvnw clean install
git clone git@github.com:microsoft/vscode-java-test.git ~/.config/nvim/vscode-java-test
cd ~/.config/nvim/vscode-java-test
npm i
npm run build-plugin
```

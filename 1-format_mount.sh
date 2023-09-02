#!/bin/bash

#-------------#-----------------------#
# Subvolume   # Mountpoint            #
#-------------#-----------------------#
# @           # /                     #
# @home       # /home                 #
# @.snapshots # /.snapshots           #
# @nix        # /nix                  #
#-------------#-----------------------#

mkfs.fat -F32 /dev/nvme0n1p1 -n "EFI"
cryptsetup --cipher aes-xts-plain64 --hash sha512 --use-random --verify-passphrase luksFormat /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 cryptroot
mkfs.btrfs -f /dev/mapper/cryptroot -L "BTRFS"

mount /dev/mapper/cryptroot /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@.snapshots
btrfs su cr /mnt/@nix

umount /mnt

mount -o defaults,noatime,compress=zstd,discard=async,space_cache=v2,autodefrag,subvol=@ /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{home,boot,nix,.snapshots}
mount -o defaults,noatime,compress=zstd,discard=async,space_cache=v2,autodefrag,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o defaults,noatime,compress=zstd,discard=async,space_cache=v2,autodefrag,subvol=@.snapshots /dev/mapper/cryptroot /mnt/.snapshots
mount -o defaults,noatime,compress=zstd,discard=async,space_cache=v2,autodefrag,subvol=@nix /dev/mapper/cryptroot /mnt/nix
mount /dev/nvme0n1p1 /mnt/boot

#!/usr/bin/env bash
set -eu
if [ $USER != root ]; then
  echo 'you must be root!' 1>&2
  exit 1
fi

[ " ${disks[*]} " =~ " ${bootable} " ] && \
  SHARED_BOOT=true || \
  SHARED_BOOT=false

main=1
swap=2
boot=3
for disk in "${disks[@]}"; do
  parted "$disk" -- mklabel gpt
  if $SHARED_BOOT; then
    parted "$disk" -- mkpart primary 512MiB -8GiB
  else
    parted "$disk" -- mkpart primary 1MiB -8GiB
  fi
  parted "$disk" -- mkpart primary linux-swap -8GiB 100%

  if $SHARED_BOOT; then
    parted "$disk" -- mkpart ESP fat32 1MiB 512MiB
    parted "$disk" -- set 3 esp on
    mkfs.fat -F 32 -n EFI "${disk}$boot"
  fi
  mkswap -L swap "${disk}$swap"
done

mirror=
if [ ${#disks[@]} -gt 1 ]; then
  mirror="mirror"
fi

zpool create \
  -o ashift=12 \
  -o autotrim=on \
  -R /mnt \
  -O canmount=off \
  -O atime=off \
  -O mountpoint=none \
  -O acltype=posixacl \
  -O compression=lz4 \
  -O dnodesize=auto \
  -O normalization=formD \
  -O relatime=on \
  -O xattr=sa \
  -O encryption=aes-256-gcm \
  -O keylocation=prompt \
  -O keyformat=passphrase \
  -O refreservation=1G \
  zoot $mirror "${disks[@]/%/$main}"

zfs create -p -o mountpoint=legacy zoot/system
zfs create -o mountpoint=legacy  zoot/system/{root,nix}
zfs create -o mountpoint=legacy  zoot/persist
zfs snapshot zoot/system/root/@blank

zfs create -o canmount=off zoot/user
zfs create -o canmount=on -o mountpoint=legacy zoot/user/home
zfs create -o canmount=on -o mountpoint=legacy zoot/user/home/root
# Create child datasets of home for users' home directories.
zfs create -o canmount=on zoot/user/home/$user

# And a media container
zfs create -o canmount=on -o mountpoint=/media zoot/media

mkdir -p /mnt/{persist,nix,boot,root,media,home/$user}

mount -t zfs zoot/system/root /mnt
mount -t zfs zoot/system/nix /mnt/nix
mount -t zfs zoot/persist /mnt/persist
mount -t zfs zoot/user/home /mnt/home
mount -t zfs zoot/user/home/root /mnt/root
mount -t zfs zoot/user/home/$user /mnt/home/$user
mount -t zfs zoot/media /mnt/media

if $SHARED_BOOT; then
  mount "${bootable}$boot" /mnt/boot
else
  parted "$bootable" -- mklabel gpt
  parted "$bootable" -- mkpart primary 512MiB 100%

  parted "$bootable" -- mkpart ESP fat32 1MiB 512MiB
  parted "$bootable" -- set 2 esp on
  mkfs.fat -F 32 -n EFI "${bootable}2"

  mount "${bootable}2" /mnt/boot
fi

# TODO: !! copy dots here
mkdir -p /mnt/home/$user/.dots

cp $tmp_install_dir/machine.nix /mnt/home/$user/.dots/nix/machines/$hostname.nix
cp $tmp_install_dir/flake.nix /mnt/home/$user/.dots/
nixos-generate-config --root /mnt --show-hardware-config > \
  /mnt/home/$user/.dots/nix/machines/hardware/$hostname.nix

nixos-install \
  --flake "/mnt/persist/dots#$hostname"
  --no-root-passwd \
  --cores 0 \
  --no-channel-copy

cd /
umount -R /mnt
zpool export zoot
echo 'You can reboot now (:'

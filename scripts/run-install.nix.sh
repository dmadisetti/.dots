#!/usr/bin/env bash
set -eux
if [ $USER != root ]; then
  echo 'you must be root!' 1>&2
  exit 1
fi

if [ "$user" == "" ]; then
  user=$nix_user
fi

encrypt_flags=
if [ "$zfs_encrypted" == "true" ]; then
  encrypt_flags="-O encryption=aes-256-gcm \
  -O keylocation=prompt \
  -O keyformat=passphrase"
fi

[[ " ${disks[*]} " =~ " ${bootable} " ]] &&
  SHARED_BOOT=true ||
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
  mirror="raidz"
  # mirror="mirror"
fi

zpool destroy $zfs_pool 2> /dev/null || true
zpool create -f \
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
  -O refreservation=1G \
  $encrypt_flags \
  $zfs_pool $mirror "${disks[@]/%/$main}"

zfs create -p -o mountpoint=legacy $zfs_pool/system
zfs create -o mountpoint=legacy $zfs_pool/system/root
zfs create -o mountpoint=legacy $zfs_pool/system/nix
zfs create -o mountpoint=legacy $zfs_pool/persist
zfs snapshot $zfs_pool/system/root@blank

zfs create -o canmount=off $zfs_pool/user
zfs create -o canmount=on -o mountpoint=legacy $zfs_pool/user/home
zfs create -o canmount=on -o mountpoint=legacy $zfs_pool/user/home/root
# Create child datasets of home for users' home directories.
zfs create -o canmount=on $zfs_pool/user/home/$user

# And a media container
zfs create -o canmount=on -o mountpoint=legacy $zfs_pool/media

mkdir -p /mnt/
mount -t zfs $zfs_pool/system/root /mnt

mkdir -p /mnt/{persist,nix,boot,root,media,home}
mount -t zfs $zfs_pool/system/nix /mnt/nix
mount -t zfs $zfs_pool/persist /mnt/persist
mount -t zfs $zfs_pool/user/home /mnt/home
mount -t zfs $zfs_pool/user/home/root /mnt/root

mkdir -p /mnt/home/$user
mount -t zfs $zfs_pool/user/home/$user /mnt/home/$user

mount -t zfs $zfs_pool/media /mnt/media

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

# Move over generated files
cp -R $DOTFILES /mnt/home/$user/.dots
cp $tmp_install_dir/machine.nix \
  /mnt/home/$user/.dots/nix/machines/$hostname.nix
cp $tmp_install_dir/flake.nix /mnt/home/$user/.dots/
if [ "$dont_refresh" != "true" ]; then
  rm -rf /mnt/home/$user/.dots/nix/sensitive
  mkdir -p /mnt/home/$user/.dots/nix/sensitive
  cp $tmp_install_dir/sensitive.nix \
    /mnt/home/$user/.dots/nix/sensitive/flake.nix
fi

DOTFILES=/mnt/home/$user/.dots
set_sensitive

nixos-generate-config --root /mnt \
  --show-hardware-config > /mnt/home/$user/.dots/nix/machines/hardware/$hostname.nix

cd $DOTFILES
git init .
git add --all --ignore-errors || :
cd /

nixos-install \
  --flake "$DOTFILES#$hostname" \
  --override-input sensitive $DOTFILES/nix/sensitive \
  --cores 0 \
  --no-channel-copy

cd /
umount -R /mnt
zpool export $zfs_pool

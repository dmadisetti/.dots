#!/usr/bin/env bash
# Provisioned from install.nix
user=""
hostname="hoss"
disks=( $(echo "sdc" "sdd" "sde" "sdf") )
bootable="sdb"
zfs_encrypted="true"
zfs_pool="zoot"
dont_refresh="true"

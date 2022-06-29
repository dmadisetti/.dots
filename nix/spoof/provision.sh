#!/usr/bin/env bash
# Provisioned from install.nix
user="{{user}}"
hostname="{{installation_hostname}}"
disks=( $(echo "{{{installation_zfs_disks}}}") )
bootable="{{installation_zfs_bootable}}"
zfs_encrypted="{{installation_zfs_encrypted}}"
zfs_pool="{{installation_zfs_pool}}"
dont_refresh="{{dont_refresh}}"

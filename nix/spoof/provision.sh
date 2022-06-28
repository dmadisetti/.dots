#!/usr/bin/env bash
# Provisioned from install.nix
user="{{user}}"
hostname="{{installation_hostname}}"
do_partition="{{installation_zfs_enabled}}"
disks=( $(echo "{{{installation_zfs_disks}}}") )
bootable="{{installation_zfs_bootable}}"
encrypted="{{installation_zfs_encrypted}}"
installation_source="{{installation_source}}"

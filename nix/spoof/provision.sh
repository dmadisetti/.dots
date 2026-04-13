#!/usr/bin/env bash
# Provisioned from install.nix
user="{{user}}"
install={{#if installation}}"true"{{else}}"false"{{/if}}
hostname="{{installation_hostname}}"
disks=( $(echo "{{{installation_zfs_disks}}}") )
bootable="{{installation_zfs_bootable}}"
zfs_encrypted="{{installation_zfs_encrypted}}"
zfs_pool="{{installation_zfs_pool}}"
dont_refresh="{{dont_refresh}}"

has_disko="{{installation_disko}}"

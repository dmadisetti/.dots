# Custom ISO image
{ lib, self, pkgs, config, modulesPath, user, sensitive, ... }:
with lib;
let
  hostName = "momento";
  nixRev = self.inputs.nixpkgs.shortRev;
  selfRev = if self ? rev then self.shortRev else "dirty";
in
{
  # For reference, see //blog.thomasheartman.com/posts/building-a-custom-nixos-installer
  # but obviously flakified and broken apart.
  imports = [
    # base profiles
    "${modulesPath}/profiles/base.nix"
    "${modulesPath}/profiles/all-hardware.nix"

    # Let's get it booted in here
    "${modulesPath}/installer/cd-dvd/iso-image.nix"

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    "${modulesPath}/installer/cd-dvd/channel.nix"
  ];

  # who's a forgetful device?
  networking.hostName = hostName;

  # Run through tor because finger printing or something? Supposed to be
  # relatively amnesiac.
  services.tor.client.enable = true;
  services.tor.enable = true;

  users.mutableUsers = false;
  users.users."${user}".initialHashedPassword = sensitive.lib.hashed;

  # ISO naming.
  isoImage.isoName = ''${hostName}-${nixRev}-${selfRev}.iso'';

  # EFI + USB bootable
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

  # Other cases
  isoImage.appendToMenuLabel = " live";
  ## add self?
  isoImage.contents = [
    {
      source = pkgs.writeText "paper.gpg" sensitive.lib.paper;
      target = "/paper.gpg";
    }
  ];
  # isoFileSystems <- add luks
  # background image
  # Grub theme

  # Add Memtest86+ to the ISO.
  boot.loader.grub.memtest86.enable = true;

  # An installation media cannot tolerate a host config defined file
  # system layout on a fresh machine, before it has been formatted.
  swapDevices = mkImageMediaOverride [ ];
  fileSystems = mkImageMediaOverride config.lib.isoFileSystems;
}

# Machine level configuaration for lambda
# See 'dots-help' or 'nixos-help'.

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware/lambda.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  # Select internationalisation properties.
  networking.hostName = "lambda"; # Define your hostname.
  networking.hostId = "001a3bda";

  i18n.defaultLocale = "en_US.UTF-8";
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  /* zfs */
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/";
  services.zfs = {
    trim.enable = true;
    autoScrub = {
      enable = true;
      pools = [ "zoot" ];
    };
  };
  #
}

# Machine level configuaration for {{installation_hostname}}
# See 'dots-help' or 'nixos-help'.

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      "./hardware/{{installation_hostname}}.nix"
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  # Select internationalisation properties.
  networking.hostName = "{{installation_hostname}}"; # Define your hostname.
  networking.hostId = "{{installation_hostid}}";

  i18n.defaultLocale = "en_US.UTF-8";
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  /* {{#if installation_zfs}}zfs */
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/";
  services.zfs = {
    trim.enable = true;
    autoScrub = {
      enable = true;
      pools = [ "{{{installation_zfs_pool}}}" ];
    };
  };
  #{{else}}*/{{/if}}
}

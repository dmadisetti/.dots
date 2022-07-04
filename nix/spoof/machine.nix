# Machine level configuaration for {{installation_hostname}}
# See 'dots-help' or 'nixos-help'.

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /* {{#unless installation_hostname}} */
      # {{else}} */ ./hardware/{{installation_hostname}}.nix
      # {{/unless}}
    ];

  # Host info
  networking.hostName = "{{installation_hostname}}";
  networking.hostId = "{{installation_hostid}}";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

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

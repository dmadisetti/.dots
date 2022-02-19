# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, self, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware/mamba.nix
      self.inputs.grub2-themes.nixosModule
    ];

  # Allow for dualboot
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      version = 2;
      device = "nodev";
      configurationLimit = 5;
      extraEntries = ''
        menuentry "Windows" --class=windows {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
    };
    grub2-theme = {
      # enable = true;
      icon = "color";
      theme = "stylish";
      screen = "1080p";
    };
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "mamba"; # Define your hostname.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;
}

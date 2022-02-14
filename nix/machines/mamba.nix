# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware/mamba.nix
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
        menuentry "Windows" {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
}

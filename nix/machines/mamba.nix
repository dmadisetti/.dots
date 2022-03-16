# Fancy grub and networking

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
        menuentry "Windows" --class windows {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
    };
    grub2-theme = {
      enable = true;
      icon = "white";
      theme = "whitesur";
      screen = "1080p";
      splashImage = ../../backgrounds/grub.jpg;
      footer = true;
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

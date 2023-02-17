# Fancy grub and networking

{ self, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware/mamba.nix
    (import ./common/fancy-grub.nix {
      splash = ../../dot/backgrounds/grub.jpg;
      windows = true;
    })
  ];

  networking.hostName = "mamba"; # Define your hostname.

  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  # I hate printers
  # services.printing.enable = true;
  # services.printing.drivers = [ pkgs.hplip ];
}

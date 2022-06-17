# Nix
{ ... }: {
  imports = [
    # System generated during install
    ./hardware/exalt.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "exalt";
  networking.nameservers = [ "10.0.0.1" "1.1.1.1" "8.8.8.8" ];

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp2s0.useDHCP = true;

  # List services that you want to enable:
  services.ntp.enable = true;
  services.openssh.enable = true;
}

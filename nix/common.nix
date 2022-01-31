# Common Nix
# ❄️
{ config, self, pkgs, user, sensitive, ... }:
{
  imports = [
    # Basic network hardening
    ./common/harden.nix
    # Very minimal packages
    ./common/pkgs.nix
  ];

  # Flakes need to be bootstrapped
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "${user}" ];

    # The default is 03:15 for when these run.
    gc.automatic = true;
    optimise.automatic = true;
    autoOptimiseStore = true;
  };

  time.timeZone = "America/New_York";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.mutableUsers = false;
  users.users."${user}" = if !config.boot.isContainer then {
    isNormalUser = true;
    uid = 1337;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "docker" "tty" "audio" "video" ];
  } else {
    isNormalUser = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11";
  system.configurationRevision = pkgs.lib.mkIf (self ? rev) self.rev;
}

# Common Nix
# ❄️
{ config, self, pkgs, user, isContainer, stateVersion, ... }: {
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

    # The default is 03:15 for when these run.
    gc.automatic = true;
    optimise.automatic = true;
    settings = {
      trusted-users = [ "root" "${user}" ];
      auto-optimise-store = true;
    };
  };

  time.timeZone = "America/New_York";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.mutableUsers = false;
  boot.isContainer = isContainer;
  users.users."${user}" =
    if !config.boot.isContainer then {
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
  system.stateVersion = stateVersion;
  system.configurationRevision = pkgs.lib.mkIf (self ? rev) self.rev;
}

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
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations
    '';

    # The default is 03:15 for when these run.
    gc.automatic = true;
    # Note, this isn't enough. I'm OK with this, but look at this for more details
    # https://www.reddit.com/r/NixOS/comments/140z3hd

    optimise.automatic = true;
    settings = {
      trusted-users = [ "root" "${user}" ];
      auto-optimise-store = true;
    };

    # Registry should be consistent
    # see:
    #  https://dataswamp.org/~solene/2022-07-20-nixos-flakes-command-sync-with-system.html
    registry.nixpkgs.flake = self.inputs.nixpkgs;
    # Likewise for legacy, keep channels synced.
    nixPath = [
      "nixpkgs=/etc/channels/nixpkgs"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };
  environment.etc."channels/nixpkgs".source = self.inputs.nixpkgs.outPath;

  time.timeZone = self.inputs.sensitive.lib.timeZone or "America/New_York";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.mutableUsers = false;
  boot.isContainer = isContainer;
  users.users."${user}" =
    (if !config.boot.isContainer then {
      isNormalUser = true;
      uid = 1337;
      shell = pkgs.fish;
      extraGroups = [ "wheel" "tty" "audio" "video" "plugdev" "docker" ];
    } else {
      isNormalUser = true;
    }) // {
      # If provided then provision.
      openssh.authorizedKeys.keys =
        if self.inputs.sensitive.lib ? "ssh-keys" then
          self.inputs.sensitive.lib.ssh-keys
        else [ ];
    };
  # Make plugdev and docker if they do not exist
  users.groups = {
    plugdev = { };
    docker = { };
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

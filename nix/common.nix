# Common Nix
{ config, pkgs, inputs, sensitive, ... }:

{
  imports = [
    # Basic network hardening
    ./common/harden.nix
  ];

  # Flakes need to be bootstrapped
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "dylan" ];
  };

  networking = sensitive.lib.networking;

  # Programs
  programs.fish.enable = true;
  programs.gnupg.agent.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.mutableUsers = false;
  users.users.dylan = {
    isNormalUser = true;
    uid = 1337;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "docker" "tty" "video" ];
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    git
    fish
    neovim
    nixpkgs-fmt

    # Basic utils
    killall
  ];

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11";
}

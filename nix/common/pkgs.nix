# Common Nix
{ config, pkgs, inputs, sensitive, ... }:

{
  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    git
    fish
    neovim
    nixpkgs-fmt

    # Basic utils
    killall
  ];

  # Override defaults
  environment.defaultPackages = with pkgs; [
    # Removes nano by omission
    perl
    rsync
    strace
  ];
  environment.variables.EDITOR = "nvim";
}


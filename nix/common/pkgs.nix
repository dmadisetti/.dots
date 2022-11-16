# Common Nix
{ pkgs, lib, ... }: {
  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    git
    git-lfs
    fish
    neovim
    nixpkgs-fmt
    nixos-option

    # Basic utils
    killall
  ];

  # Override defaults
  environment.defaultPackages = lib.mkForce [
    # Removes nano/perl/rsync by omission
    pkgs.strace
  ];
  environment.variables.EDITOR = "nvim";
}


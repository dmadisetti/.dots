# Under imports in /etc/nixos/configuration.nix
# /home/nixos/.dotfiles/nix/bootstrap/boostrap.nix
{ lib, pkgs, config, modulesPath, ... }:

{
  # Install flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    git
    fish
    neovim
    nixpkgs-fmt
    keybase
    kbfs
    # Basic utils
    killall
  ];

  users.users.dylan = {
    isNormalUser = true;
    uid = 1337;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "docker" ];
  };

  services = {
    keybase.enable = true;
    kbfs = {
      enable = true;
      mountPoint = "keybase";
    };
  };
}


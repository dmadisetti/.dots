# Let's manage some packages!
{ pkgs, ... }: {
  home.packages = with pkgs; [ home-manager nixpkgs-fmt nixos-option ];
}

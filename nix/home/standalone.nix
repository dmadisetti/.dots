# Let's manage some packages!

{ pkgs, inputs, system, ... }:

{
  home.packages = with pkgs; [
    home-manager
    nixpkgs-fmt
    nixos-option
  ];
}

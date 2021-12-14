# Tell it how it is

{ pkgs, inputs, home, system, ... }:

{
  imports = [ ];
  home.packages = with pkgs; [
    kitty
  ];
}

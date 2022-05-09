# Just a stub!

args@{ inputs, pkgs, stateVersion, ... }:
let
  propagate = f: extra@{ ... }: (import f (args // extra));
in
{
  imports = [
    (propagate ../home/common.nix)
    # Fish is needed for various helper commands.
    (propagate ../programs/fish.nix)
  ];

  home.packages = with pkgs; [ ];
}

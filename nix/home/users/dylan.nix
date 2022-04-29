# Home sweet home 🏠

args@{ inputs, pkgs, stateVersion, ... }:
let
  propagate = f: extra@{ ... }: (import f (args // extra));
in
{
  # You can rename this file to your main username;
  # you'll just need to update inputs.spoof.lib.user accordingly
  # and leave a stub for user.nix (see spoof/user.nix)

  imports = [
    (propagate ../common.nix)
    ../programs/gpg.nix
    ../programs/nvim.nix
    (propagate ../programs/git.nix)
    (propagate ../programs/fish.nix)
  ] ++ (if inputs.sensitive.lib ? cachix then [
    inputs.declarative-cachix.homeManagerModules.declarative-cachix
    (propagate ../programs/cachix.nix { cache = inputs.sensitive.lib.cachix; })
  ] else [ ]) ++ (if inputs.sensitive.lib.keybase.enable then [
    ../programs/keybase.nix
  ] else [ ]);

  home.packages = with pkgs; [
    # security
    wireguard-tools

    # all ya really need
    tmux

    # cool little extensions
    any-nix-shell
  ];
}

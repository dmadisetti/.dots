# Home sweet home 🏠

args@{ inputs, self, pkgs, stateVersion, ... }:
let propagate = f: extra: (import f (args // extra));
in
{
  # you can rename this file to your main username;
  # you'll just need to update inputs.spoof.lib.user accordingly.
  # if not defined in main, user.nix will be filled from a stub (see spoof/user.nix)
  # for basic workflow tasks.

  imports = [
    (propagate ../common.nix)
    ../programs/gpg.nix
    ../programs/nvim.nix
    (propagate ../programs/git.nix)
    (propagate ../programs/fish.nix)
  ] ++ (if inputs.sensitive.lib ? cachix then [
    inputs.declarative-cachix.homeManagerModules.declarative-cachix
    (propagate ../programs/cachix.nix { cache = inputs.sensitive.lib.cachix; })
  ] else
    [ ]) ++ (if inputs.sensitive.lib.keybase.enable then
    [ ../programs/keybase.nix ]
  else
    [ ]);

  home.packages = with pkgs; [
    # security
    wireguard-tools

    # all ya really need
    tmux

    # cool little extensions
    any-nix-shell
  ];
}

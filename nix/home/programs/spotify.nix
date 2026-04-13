# Jazz hands
# Note, you'll have to set either:
# sensitive.lib.unfree = ["spotify"] or sensitive.lib.sellout = true
{ inputs, pkgs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  # import the flake's module for your system
  # imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  # configure spicetify :)
  # programs.spicetify =
  #   {
  #     enable = true;
  #     # Just the default, but works pretty nicely
  #     # theme = spicePkgs.themes.catppuccin-mocha;
  #     colorScheme = "dracula";

  #     enabledExtensions = with spicePkgs.extensions; [
  #       fullAppDisplay
  #       shuffle # shuffle+ (special characters are sanitized out of ext names)
  #       hidePodcasts
  #     ];
  #   };
}

# Shared by er'one
{ config, pkgs, self, stateVersion, ... }:
let
  # Work around to allow overloading
  base_config = ".config/nix/nix.conf";
  nix_config = if config ? "caches" then ".nixConf" else "${base_config}";
in
{
  imports = [ ];

  # Derived script to pretty print messages.
  home.packages = with pkgs; [ self.outputs._prettyprint jq ];

  home.sessionVariables = {
    XDG_DOWNLOAD_DIR = "$HOME/downloads";
  };

  # Make sure flakes work by default..
  home.file."${nix_config}".text = ''
    experimental-features = nix-command flakes ca-derivations ''
  + (
    if pkgs.config.contentAddressedByDefault then "" else "ca-derivations"
  );
  home.stateVersion = stateVersion;
}

# Shared by er'one
{ stateVersion, ... }:
{
  imports = [ ];

  # Make sure flakes work by default..
  home.file.nixConf.text = ''
    experimental-features = nix-command flakes
  '';
  home.stateVersion = stateVersion;
}

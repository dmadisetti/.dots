# Self reference as read only for isos

{ config, inputs, ... }:
{
  imports = [ ];
  home.file.".dots".source = ../../.;

  home.sessionVariables = {
    LIVE = 1;
    KEYBASE_USER = inputs.sensitive.lib.keybase.username;
  };
}

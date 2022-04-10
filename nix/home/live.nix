# Self reference as read only for isos

{ config, inputs, ... }:
{
  imports = [ ];
  home.file.".ro-dots".source = ../../.;

  home.sessionVariables = {
    LIVE = 1;
    KEYBASE_USER = inputs.sensitive.lib.keybase.username;
  };
}

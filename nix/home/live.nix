# Self reference as read only for isos

{ config, sensitive, ... }:
{
  imports = [ ];
  home.file.".dots".source = ../../.;

  home.sessionVariables = {
    LIVE = 1;
    KEYBASE_USER = sensitive.lib.keybase_user;
  };
}

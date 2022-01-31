# Self reference as read only for isos

{ config, ... }:
{
  imports = [ ];
  home.file.".dots".source = ../../.;
}

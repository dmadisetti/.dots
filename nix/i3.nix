# Tell it how it is

{ pkgs, inputs, home, system, ... }:

{
  imports = [ ];

  xsession.windowManager.i3 = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  home.packages = with pkgs; [
    kitty
  ];
}

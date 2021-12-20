# Tell it how it is

{ pkgs, lib, home, ... }:

{
  imports = [ ];

  xsession.windowManager.xmonad = {
    enable = true;
    extraPackages = haskellPackages: [
      haskellPackages.xmonad-contrib
      haskellPackages.containers
    ];
    enableContribAndExtras = true;
  };

  home.packages = with pkgs; [
    acpi
    jq
    dunst
    eww
    feh
    maim
    picom
    rofi
  ];

  home.file.".xinitrc".source = ../../config/xmonad/xinitrc;
}

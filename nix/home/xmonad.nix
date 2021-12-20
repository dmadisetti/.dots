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
    config = ../../config/xmonad/Main.hs;
  };

  home.packages = with pkgs; [
    acpi
    dunst
    eww
    feh
    jq
    maim
    picom
    rofi
    steam-tui
    steamcmd

    # isn't tweag the best
    ormolu
  ];

  home.file.".xinitrc".source = ../../config/xmonad/xinitrc;
}

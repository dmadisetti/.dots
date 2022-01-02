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
    # utils
    acpi # hardware states
    brightnessctl # Control background
    playerctl # Control audio
    jq # parse json

    # rice
    betterlockscreen # ok lockscreen
    dunst # notifications
    eww # bars and widgets
    feh # background
    picom # Compositor

    # nice
    maim # Screenshot
    rofi # quick start
    clipcat # Clipboard

    zathura # pdfs

    # isn't tweag the best
    ormolu
  ];

  home.file.".xinitrc".source = ../../config/xmonad/xinitrc;
}

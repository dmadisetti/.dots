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
    acpi # hardware states
    brightnessctl
    playerctl
    betterlockscreen
    dunst # notifications
    eww # bars and widgets
    feh # background
    jq # parse json
    maim # Screenshot
    picom # Compositor
    imagemagick # TODO: remove
    libnotify
    rofi # quick start

    zathura # pdfs

    # Games for fun
    steam-tui
    steamcmd

    # isn't tweag the best
    ormolu
  ];

  home.file.".xinitrc".source = ../../config/xmonad/xinitrc;
}

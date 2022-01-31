# Sipping once 🥣, sipping twice 🥣
# Sipping chicken noodle soup with rice.

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
    config = ../../dot/xmonad/Main.hs;
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
  ];

  home.file.".xinitrc".source = ../../dot/xmonad/xinitrc;
}

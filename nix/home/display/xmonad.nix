# Sipping once 🥣, sipping twice 🥣
# Sipping chicken noodle soup with rice.
{ pkgs, home, ... }: {
  imports = [ ../programs/eww.nix ../programs/polybar.nix ];

  xsession.windowManager.xmonad = {
    enable = true;
    extraPackages = haskellPackages: [
      haskellPackages.xmonad-contrib
      haskellPackages.containers
    ];
    enableContribAndExtras = true;
    config = ../../../dot/xmonad/Main.hs;
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
    feh # background
    picom # Compositor

    # nice
    maim # Screenshot
    rofi # quick start
    clipcat # Clipboard
  ];

  home.file.".xinitrc".source = ../../../dot/xmonad/xinitrc;
}

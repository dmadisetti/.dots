# Tell it how it is
{ pkgs, home, inputs, ... }: {
  imports = [ ];


  home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";

  home.packages = with pkgs; [
    # utils
    acpi # hardware states
    brightnessctl # Control background
    playerctl # Control audio

    inputs.hyprland.packages."x86_64-linux".default
    eww-wayland
    wl-clipboard
    rofi
    grim
    # from overlay
    mpvpaper
  ];
}

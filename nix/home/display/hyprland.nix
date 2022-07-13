# Tell it how it is
{ pkgs, home, inputs, ... }: {
  imports = [ ];

  # I kinda like the white cursor
  home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
  home.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = 1;
  };

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

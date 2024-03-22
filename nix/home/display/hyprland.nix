# Tell it how it is
{ pkgs, home, inputs, ... }: {
  imports = (if inputs.sensitive.lib ? cachix then [
    {
      caches.extraCaches = [{
        url = "https://hyprland.cachix.org";
        key = "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
      }];
    }
  ] else [ ]);

  # I kinda like the white cursor
  home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
  home.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = 1;
    NIXOS_OZONE_WL = 1;
  };

  home.packages = with pkgs; [
    # utils
    acpi # hardware states
    brightnessctl # Control background
    playerctl # Control audio

    (inputs.hyprland.packages."x86_64-linux".hyprland.override {
      # enableNvidiaPatches = true;
    })
    eww
    wl-clipboard
    rofi
    grim
    # from overlay
    mpvpaper
  ];
}

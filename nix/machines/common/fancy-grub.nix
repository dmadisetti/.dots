# Fancy grub and networking
{ splash, windows ? false, short ? false, footer ? true }:
{ self, lib, ... }: {
  imports = [ self.inputs.grub2-themes.nixosModules.default ];

  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      configurationLimit = 5;
      # Allow for dualboot
      extraEntries = lib.mkIf windows ''
        menuentry "Windows" --class windows {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
    };
    grub2-theme = {
      enable = true;
      icon = "white";
      theme = "whitesur";
      screen = "1080p";
      splashImage = splash;
      footer = footer;
      bootMenuConfig = lib.mkIf short ''
        left = 35%
        top = 20%
        width = 30%
        height = 40%
        item_font = "Unifont Regular 16"
        item_color = "#cccccc"
        selected_item_color = "#ffffff"
        icon_width = 32
        icon_height = 32
        item_icon_space = 20
        item_height = 36
        item_padding = 5
        item_spacing = 10
        selected_item_pixmap_style = "select_*.png"
      '';
    };
    efi.canTouchEfiVariables = true;
  };
}

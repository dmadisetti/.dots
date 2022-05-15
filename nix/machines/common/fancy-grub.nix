# Fancy grub and networking
{ splash, windows ? false }:
{ self, lib, ... }:

{
  imports = [ self.inputs.grub2-themes.nixosModule ];

  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      version = 2;
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
      footer = true;
    };
    efi.canTouchEfiVariables = true;
  };
}

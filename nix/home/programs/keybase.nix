# 🗝️
{ home, pkgs, ... }: {
  imports = [ ];

  home.packages = with pkgs; [ keybase ];
  services = {
    keybase.enable = true;
    kbfs = {
      enable = true;
      mountPoint = "keybase";
    };
  };
}

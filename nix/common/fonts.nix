# Fonts!
{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    fira-code
    fira-code-symbols

    material-design-icons
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  # Manually set font to get a few more unicode characters. See ./getty.nix
  i18n = { defaultLocale = "en_US.UTF-8"; };
  console = {
    earlySetup = true;
    font = "latarcyrheb-sun16"; # Default on Fedora, and looks nice enough.
  };
}

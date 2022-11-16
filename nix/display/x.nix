# Common Nix
{ ... }: {
  imports = [ ];
  environment.pathsToLink =
    [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver = {
    enable = true;
    libinput.enable = true;
    displayManager.startx.enable = true;
    desktopManager.xterm.enable = false;
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
}

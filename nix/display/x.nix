# Common Nix
{ ... }: {
  imports = [ ];
  environment.pathsToLink =
    [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    desktopManager.xterm.enable = false;
  };
  services.libinput.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
}

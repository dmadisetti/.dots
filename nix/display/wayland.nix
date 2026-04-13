# Common Nix
{ ... }: {
  imports = [ ];
  hardware.graphics.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  xdg.portal.wlr.enable = true;
  xdg.portal.config.common.default = "*";
  services.dbus.enable = true;
}

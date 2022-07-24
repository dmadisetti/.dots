# Come sway or not, we all love polybar
{ _ }: {
  services = {
    polybar = {
      enable = true;
      config = ../../../dot/config/polybar/config.ini;
      script = "polybar bar &";
    };
  };
}

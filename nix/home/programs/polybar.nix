# Come sway or not, we all love polybar
{ ... }: {
  services = {
    polybar = {
      enable = true;
      config = ../../../dot/config/polybar/config.ini;
      script = "polybar bar &";
    };
  };
}

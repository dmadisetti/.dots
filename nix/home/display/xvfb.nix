# Like a headless chicken
{ pkgs, home, ... }: {
  imports = [ ];

  home.packages = with pkgs; [
    xvfb-run
    ffmpeg_5-full
  ];

  home.file.".xinitrc".source = ../../../dot/xvfb/xinitrc;
}

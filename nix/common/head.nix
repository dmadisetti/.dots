# If we can actually sit at the computer
{ config, pkgs, inputs, sensitive, ... }:

{
  # Programs
  programs.fish.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
}

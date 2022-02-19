# If we can actually sit at the computer
{ config, pkgs, lib, inputs, sensitive, ... }:
{
  # Programs
  programs.fish.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Networking should only be allowed on machines with a head.
  # Otherwise it should be custom, or default to host
  networking = sensitive.lib.networking;

  # Disable wireguard service out the gate.
  systemd.services."wg-quick-wg0".wantedBy = lib.mkForce [ ];
}

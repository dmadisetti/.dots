# If we can actually sit at the computer
{ lib, sensitive, ... }: {
  # Networking should only be allowed on machines with a head.
  # Otherwise it should be custom, or default to host
  inherit (sensitive.lib) networking;

  # Programs
  programs.fish.enable = true;

  # Disable wireguard service out the gate.
  systemd.services."wg-quick-wg0".wantedBy = lib.mkForce [ ];
}

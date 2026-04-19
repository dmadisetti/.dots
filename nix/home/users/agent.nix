# Minimal agent home — cowboy home module provides the rest
{ pkgs, inputs, ... }:

{
  imports = [
    inputs.cowboy.homeModules.agent
  ];

  # home-manager options only - services.cowboy is set in nixos config
  home.homeDirectory = "/home/agent";

  home.packages = with pkgs; [
    bind      # for dig
    iputils   # for ping
    curl
  ];
}

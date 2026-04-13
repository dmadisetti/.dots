# Minimal agent home — cowboy home module provides the rest
{ pkgs, inputs, ... }:

{
  imports = [
    inputs.cowboy.homeModules.agent
  ];

  services.cowboy = {
    enable = true;
    agent = {
      enable = true;
      defaultSkills = true;
    };
  };

  home.homeDirectory = "/home/agent";

  home.packages = with pkgs; [
    bind      # for dig
    iputils   # for ping
    curl
  ];
}

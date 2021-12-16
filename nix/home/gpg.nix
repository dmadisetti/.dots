# Gotta encrypt it to believe it
{ pkgs, inputs, system, ... }:

{
  imports = [ ];

  # PGP settings for headless pinentry
  home.file.".gnupg/gpg-agent.conf".text = "allow-loopback-pinentry";
  home.file.".gnupg/gpg.conf".text = "pinentry-mode loopback";
}

# Gotta encrypt it to believe it 🔒
{ ... }:
{
  imports = [ ];

  # PGP settings for headless pinentry
  home.file.".gnupg/gpg-agent.conf".text = ''
    default-cache-ttl 34560000
    max-cache-ttl 34560000
    allow-loopback-pinentry'';
  home.file.".gnupg/gpg.conf".text = "pinentry-mode loopback";
}

{ config, pkgs, user, ... }: {
  networking.firewall.enable = true;
  security.sudo.execWheelOnly = true;

  security.auditd.enable = true;
  security.audit.enable = !config.boot.isContainer;

  # PGP set up.
  programs.gnupg.agent.enable = true;

  services = {
    openssh = {
      enable = true;
      permitRootLogin = "prohibit-password"; # distributed-build.nix requires it
      passwordAuthentication = false;
      allowSFTP = false;
    };
    fail2ban = {
      enable = true;
    };
  };
  nix.allowedUsers = [ "root" "${user}" ];
  nix.trustedUsers = [ "root" "${user}" ];
}

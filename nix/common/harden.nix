{ config, user, sensitive, lib, ... }: {
  networking.firewall.enable = true;
  security.sudo.execWheelOnly = true;

  security.auditd.enable = true;
  security.audit.enable = !config.boot.isContainer;

  # PGP set up.
  programs.gnupg.agent.enable = true;

  services = {
    openssh = {
      inherit (sensitive.lib.sshd) enable;

      ports = [ sensitive.lib.sshd.port ];
      permitRootLogin = "prohibit-password"; # distributed-build.nix requires it
      passwordAuthentication = false;
      allowSFTP = false;
    };
    fail2ban = { enable = true; };
  };
  nix.settings.allowed-users = [ "root" "${user}" ];
  nix.settings.trusted-users = [ "root" "${user}" ];

  security.pki.certificateFiles = lib.catAttrs "cert" (lib.attrValues sensitive.lib.certificates);
}

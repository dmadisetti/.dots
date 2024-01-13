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
      settings = {
        PermitRootLogin = "prohibit-password"; # distributed-build.nix requires it
        PasswordAuthentication = false;
      };
      allowSFTP = false;
    };
    fail2ban = {
      enable = true;
      # Set as default upstream,
      # but put it here explicitly.
      bantime = "10m";
    };
  };
  nix.settings.allowed-users = [ "root" "${user}" ];
  nix.settings.trusted-users = [ "root" "${user}" ];

  # TODO: Make conditional on yubi
  # Yubi?
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  security.pki.certificateFiles = (if (sensitive.lib ? "certificates") then
    (lib.catAttrs "cert" (lib.attrValues sensitive.lib.certificates)) else [ ]);
}

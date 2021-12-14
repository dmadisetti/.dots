{ pkgs, ... }: {
  networking.firewall.enable = true;
  security.sudo.execWheelOnly = true;
  security.auditd.enable = true;
  security.audit.enable = true;
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
  nix.allowedUsers = [ "root" "dylan" ];
  nix.trustedUsers = [ "root" "dylan" ];
}

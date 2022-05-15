# Fancy grub and networking

{ self, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware/brick.nix
    (import ./common/fancy-grub.nix {
      splash = ../../dot/backgrounds/grub.jpg;
    })
    (import ./common/hostapd.nix {
      dev = {
        ap = "wlp0s19f2u3";
        out = "enp4s0";
      };
      ssid = ''"🙃"'';
    })
    (import ./common/nginx.nix rec {
      tld = "brick";
      cert = if (self.inputs.sensitive.lib.certificates ? brick) then {
        crt = self.inputs.sensitive.lib.certificates.brick.cert;
        key = self.inputs.sensitive.lib.certificates.brick.key;
      } else null;
      proxies = {
        "notebook.${tld}" = { port = "8000"; };
        "~^(?<sub>.+)?\\.notebook.${tld}$" = { port = "800$sub"; };
        "notes.${tld}" = { port = "9000"; };
      };
    })
    (import ./common/nginx.nix rec {
      tld = "krack";
      cert = if (self.inputs.sensitive.lib.certificates ? krack) then {
        crt = self.inputs.sensitive.lib.certificates.krack.cert;
        key = self.inputs.sensitive.lib.certificates.krack.key;
      } else null;
      proxies = {
        "notebook.${tld}" = {
          port = "8000";
          host = "127.0.0.1";
        };
        "~^(?<sub>.+)?\\.notebook.${tld}$" = {
          port = "800$sub";
          host = "127.0.0.1";
        };
      };
    })
  ];

  networking.hostName = "brick"; # Define your hostname.
  networking.hostId = "cafecafe";
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  # nvidia
  services.xserver.videoDrivers = [ "nvidia" ];
  # lol, we rocking a 610
  hardware.nvidia.package =
    pkgs.linuxKernel.packages.linux_5_15.nvidia_x11_legacy390;
  hardware.nvidia.modesetting.enable = true;
  environment.systemPackages = with pkgs; [ nvidia-docker ];
  # something broke though
  services.xserver.dpi = 96;
  environment.variables = { GDK_SCALE = "0.5"; };

  # zfs
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/";

  services.zfs = {
    trim.enable = true;
    autoScrub = {
      enable = true;
      pools = [ "rpool" ];
    };
  };
}

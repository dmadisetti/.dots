# Machine level configuaration for lambda
# See 'dots-help' or 'nixos-help'.

{ config, pkgs, self, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware/lambda.nix

      (import ./common/fancy-grub.nix {
        splash = ../../dot/backgrounds/grub.jpg;
      })
      (import ./common/hostapd.nix {
        dev = {
          ap = "wlo1";
          out = "enp3s0";
        };
        ssid = ''🧐'';
      })
      (import ./common/nginx.nix rec {
        tld = "ave";
        cert =
          if (self.inputs.sensitive.lib.certificates ? ave) then {
            crt = self.inputs.sensitive.lib.certificates.ave.cert;
            key = self.inputs.sensitive.lib.certificates.ave.key;
          } else null;
        proxies = {
          "notebook.${tld}" = { port = "8000"; };
          "~^(?<sub>.+)?\\.notebook.${tld}$" = { port = "800$sub"; };
          "notes.${tld}" = { port = "9000"; };

          # Plex relevant
          "plex.${tld}" = { port = "32400"; };
          "sonarr.${tld}" = { port = "8989"; };
          "radarr.${tld}" = { port = "7878"; };
          "transmission.${tld}" = { port = "9091"; };
        };
      })
    ] ++ (if
      self.lib.utils.maybe self.inputs.sensitive.lib "sellout" false
    then [ ./common/plex.nix ] else [ ]);

  boot.loader.efi.canTouchEfiVariables = true;

  # Select internationalisation properties.
  networking.hostName = "lambda";
  networking.hostId = "001a3bda";

  i18n.defaultLocale = "en_US.UTF-8";
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  # nvidia
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.package =
    pkgs.linuxKernel.packages.linux_5_15.nvidia_x11;
  hardware.nvidia.modesetting.enable = true;
  # hardware.nvidia.prime.offload.enable = true;
  environment.systemPackages = with pkgs; [ nvidia-docker ];
  # something broke though
  services.xserver.dpi = 110;
  environment.variables = { GDK_SCALE = "0.3"; };

  # Bluetooth
  # https://nixos.wiki/wiki/Bluetooth
  hardware.bluetooth.enable = true;
  # Don't power up the default Bluetooth controller on boot
  hardware.bluetooth.powerOnBoot = false;
  boot.extraModprobeConfig = "options bluetooth disable_ertm=1 ";

  /* zfs */
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/";
  services.zfs = {
    trim.enable = true;
    autoScrub = {
      enable = true;
      pools = [ "zoot" ];
    };
  };
  #
}

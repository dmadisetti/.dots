# Machine level configuaration for lambda
# See 'dots-help' or 'nixos-help'.

{ config, pkgs, self, inputs, user, sensitive, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware/lambda.nix

      (import ./common/fancy-grub.nix {
        splash = ../../dot/backgrounds/lambda-grub.jpg;
        short = true;
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
            inherit (self.inputs.sensitive.lib.certificates.ave) key cert;
          } else null;
        proxies = {
          "notebook.${tld}" = {
            port = "8000";
            extra = ''
              proxy_set_header Host $host;'';
          };
          "~^(?<sub>.+)?\\.notebook.${tld}$" = { port = "800$sub"; };
          "~^(?<port>\\d+)?\\.port.${tld}$" = { port = "$port"; };
          "notes.${tld}" = {
            port = "9000";
            extra = ''
              add_header Access-Control-Allow-Origin *;
            '';
          };

          # Plex relevant
          "plex.${tld}" = { port = "32400"; };
          "sonarr.${tld}" = { port = "8989"; };
          "radarr.${tld}" = { port = "7878"; };
          "readarr.${tld}" = { port = "8787"; };
          "kavita.${tld}" = {
            port = "5000";
            # Annoyingly requires header to be set, even though there are
            # options to change the host.
            extra = ''
              proxy_set_header Host $host;
            '';
          };
          "prowlarr.${tld}" = { port = "9696"; };
          "transmission.${tld}" = { port = "9091"; };

          # Misc
          "tensorboard.${tld}" = {
            port = "6006";
            extra = ''
            '';
          };
          "home.${tld}" = { port = "8123"; };
        };
      })
      (import ./common/home-assistant.nix {
        extraComponents = [
          # Having hue forces port 80
          "hue"
          "spotify"
          "plex"
          "radarr"
          "sonarr"
          "transmission"
        ];
        customComponents = [
          # pkgs.home-assistant-custom-components.govee-lan
          (pkgs.callPackage ../pkgs/hass/garmin.nix { })
          # pkgs.home-assistant-custom-components.garmin_connect
        ];
        customModules = [
          (pkgs.callPackage ../pkgs/hass/transmission-card.nix { })
          # (pkgs.callPackage ./common/hass-pkgs/garmin.nix { })
          pkgs.home-assistant-custom-lovelace-modules.mushroom
        ];
      })

      # AI Agent system (from cowboy flake) — see nix/machines/quanta.nix in
      # harness.nix for a fully-configured reference.
      inputs.cowboy.nixosModules.default
    ] ++ (if self.inputs.sensitive.lib.sellout or false
    then [ ./common/plex.nix ] else [ ]) ++ (
      if self.inputs.sensitive.lib ? ssh-boot then
        [
          (import ./common/ssh-boot.nix {
            hostKey = self.inputs.sensitive.lib.ssh-boot.key;
            authorizedKey = self.inputs.sensitive.lib.ssh-boot.pub;
          })
        ] else [ ]
    );

  boot.loader.efi.canTouchEfiVariables = true;

  # Select internationalisation properties.
  networking.hostName = "lambda";
  networking.hostId = "001a3bda";

  i18n.defaultLocale = "en_US.UTF-8";
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  # nvidia
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
  hardware.nvidia.package = pkgs.linuxKernel.packages.linux_6_18.nvidia_x11;
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
  hardware.bluetooth.settings = {
    General = {
      ControllerMode = "dual";
      Experimental = true;
    };
  };
  boot.extraModprobeConfig = "options bluetooth disable_ertm=1 ";

  # lambda specific programs
  programs.singularity.enable = true;

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

  # Boo printing
  # services.printing.enable = true;
  # services.printing.drivers = [ pkgs.cnijfilter2 ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    glibc
    libgcc
    stdenv.cc.cc.lib
    zlib
  ];


  # For Gyro switch controllers
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0664", GROUP="plugdev"
  '';

  # Cowboy agent — hardened reference: ~/src/harness.nix/nix/machines/quanta.nix
  # See /home/dylan/.claude/plans/partitioned-skipping-summit.md for the security
  # rationale behind each knob.
  services.cowboy = {
    broker = user;                               # broker = dylan; owns proxy + bridges (accepted risk: dylan has docker/trusted-users)
    secretsProxy.enable = true;                  # CORE isolation: agent in cowboy-ns netns, all TCP DNATed to 10.200.0.1:8443, secrets injected in-flight
    # sheepdog.enable = true;                    # disabled — revisit after burn-in

    # Media stack API keys — proxy injects X-Api-Key header
    secretsProxy.domainMappings = {
      "sonarr.ave" = { secretPath = "/run/agenix/sonarr-key"; headerName = "X-Api-Key"; };
      "radarr.ave" = { secretPath = "/run/agenix/radarr-key"; headerName = "X-Api-Key"; };
    };

    pubsub = {
      redisAcl.enable = true;                    # restricts agent's redis user to xread/xack/xadd on *:inbox/*:outbox; bridges (broker) still get full Redis

      consult = {
        enable = true;                           # subagent tool; no secrets, runs as broker
        backend = "claude-code";
      };

      discord = {
        enable = true;                                                                # broker-visible inbox/outbox + approval notifications
        env = "/run/agenix/discord-env";                                              # DISCORD_BOT_TOKEN via systemd EnvironmentFile, never in /nix/store
        identities."${sensitive.lib.agent.pubsub.discord.userId}" = "User";           # maps Discord snowflake → role label (empty string OK as placeholder)
      };

      rebuild = {
        enable = true;                                                                # agent proposes rebuild, dylan approves via Discord
        repo = "dmadisetti/.dots";
        env = "/run/agenix/github-token-env";                                         # GITHUB_TOKEN=... (dedicated secret, owned by agent group)
        overrides = [
          { name = "cowboy";    path = "github:dmadisetti/cowboy"; }
          { name = "sensitive"; path = "path:/home/dylan/.dots/nix/sensitive"; }      # required: dots flake.nix points sensitive at ./nix/spoof by default
        ];
        approval = {
          required = true;                                                            # NEVER auto-apply; hold in approval hash until human ACKs
          notify_channel = sensitive.lib.agent.pubsub.discord.notifyChannelId;
        };
      };
    };

    # Polkit subsystem enable (global toggle)
    managedServices.enable = true;

    agent = {
      enable        = true;
      model         = "openrouter:moonshotai/kimi-k2.5";
      summaryModel  = "openrouter:xiaomi/mimo-v2-flash";
      compactModel  = "openrouter:xiaomi/mimo-v2-flash";
      subagentModel = "openrouter:xiaomi/mimo-v2-flash";
      judge.model   = "xiaomi/mimo-v2-flash";
      sshAuthorizedKeys = [ ];                   # add later if remote SSH into agent is desired
      dotfiles = "https://github.com/claughd/config.git";  # agent's own config repo

      skills.homeAssistant = {
        enable = true;
        endpoint = "home.ave";
        tokenPath = "/run/agenix/ha-token";
      };

      # Polkit-managed systemd units this agent can start/stop/restart.
      # Scoped to media-stack + home-assistant only — agent can NOT restart ssh,
      # nginx, the cowboy stack itself, or anything else on the host.
      managedServices.units = [
        "sonarr.service"
        "radarr.service"
        "readarr.service"
        "prowlarr.service"
        "transmission.service"
        "plex.service"
        "home-assistant.service"
      ];
    };

    # No workspace — agent works from its own dotfiles clone, not /home/dylan/.dots.
    # Rebuild bridge pulls from GitHub directly.
  };
}

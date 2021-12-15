# Nix

{ config, pkgs, ... }:

{
  imports =
    [
      # System generated during install
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Install flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  networking.hostName = "exalt";
  networking.nameservers = ["10.0.0.1" "1.1.1.1" "8.8.8.8"];
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    interfaces = [ "wlp2s0" ];
    # Come on through and use my wifi internet. That's absolutely chill. This is
    # an approach I'd like to call security through configuring wpa_supplicant
    # with unicode characters (effective, but maybe less so now that this is
    # public). Alternatively, security through friendliness (lol, I have coffee
    # and biscuits, and while you're trying to connect to my network, you want
    # some?). Finally, security through emoji (would you really hack someone
    # with an emoji for an SSID? It's so silly and fun).
    networks = {
       "\"🙃\"" = {
           "psk" = "derpderp";
       };
    };
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp2s0.useDHCP = true;

  # Programs
  programs.fish.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.mutableUsers = false;
  users.users.dylan = {
    isNormalUser = true;
    uid = 1337;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "docker" ];
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    fish
    git
    ncurses
    neovim
    python38Packages.pynvim
    tmux
  ];

  # List services that you want to enable:
  services.ntp.enable = true;
  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}


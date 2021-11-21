# Common Nix
{ config, pkgs, ... }:

{
  imports = [ ];

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

  # List packages installed in system profile. 
  environment.systemPackages = with pkgs; [
    git
    fish
    neovim
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05";
}

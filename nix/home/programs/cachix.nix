{ cache, pkgs, ... }: {
  home.packages = with pkgs; [ cachix ];

  # Cheers @thiagokokada
  # To make cachix work you need add the current user as a trusted-user on Nix
  # sudo echo "trusted-users = $(whoami)" >> /etc/nix/nix.conf
  # Another option is to add a group by prefixing it by @, e.g.:
  # sudo echo "trusted-users = @wheel" >> /etc/nix/nix.conf
  caches.cachix = [{
    name = "nix-community";
    sha256 = "00lpx4znr4dd0cc4w4q8fl97bdp7q19z1d3p50hcfxy26jz5g21g";
  }] ++ cache;

  caches.extraCaches = [{
    url = "https://cache.ngi0.nixos.org/";
    key = "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA=";
  }];
}

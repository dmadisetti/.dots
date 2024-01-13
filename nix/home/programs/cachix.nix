{ cache, self, pkgs, ... }: {
  home.packages = with pkgs; [ cachix ];

  # Cheers @thiagokokada
  # To make cachix work you need add the current user as a trusted-user on Nix
  # sudo echo "trusted-users = $(whoami)" >> /etc/nix/nix.conf
  # Another option is to add a group by prefixing it by @, e.g.:
  # sudo echo "trusted-users = @wheel" >> /etc/nix/nix.conf
  caches.cachix = [{
    name = "nix-community";
    sha256 = "0m6kb0a0m3pr6bbzqz54x37h5ri121sraj1idfmsrr6prknc7q3x";
  }] ++ cache;

  caches.extraCaches = [
    {
      url = "https://cache.ngi0.nixos.org/";
      key = "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA=";
    }
    {
      url = "https://cuda-maintainers.cachix.org";
      key = "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E=";
    }
  ];
}

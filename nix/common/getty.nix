{ config, self, sensitive, ... }:
{
  services.getty.greetingLine = ''NixOS ${config.system.nixos.release} - \l'';
  # It's a big stylized QR code. I promise, it's cool.
  services.getty.helpLine =
    let
      pkgs_rev = self.inputs.nixpkgs.shortRev;
      dots_rev = (if self ? rev then self.shortRev else "dirty");
    in
    sensitive.lib.getty pkgs_rev dots_rev;
}

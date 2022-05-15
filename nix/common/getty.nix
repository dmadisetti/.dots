{ config, self, lib, sensitive, ... }: {
  services.getty.greetingLine = ''NixOS ${config.system.nixos.release} - \l'';
  # It's a big stylized QR code. I promise, it's cool.
  services.getty.helpLine =
    let
      pkgs_rev = (if self.inputs.nixpkgs ? rev then self.inputs.nixpkgs.shortRev else "dirty");
      dots_rev = (if self ? rev then self.shortRev else "dirty");
    in
    lib.mkForce ''${sensitive.lib.getty pkgs_rev dots_rev}

    Run 'dots-help' or 'nixos-help' for more information.'';
}

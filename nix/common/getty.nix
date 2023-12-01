{ config, self, lib, sensitive, ... }: {
  services.getty.greetingLine = ''NixOS ${config.system.nixos.release} - \l'';
  # It's a big stylized QR code. I promise, it's cool.
  services.getty.helpLine =
    let
      pkgs_rev = self.inputs.nixpkgs.shortRev or "dirty";
      dots_rev = self.shortRev or "dirty";
    in
    lib.mkForce ''${if (sensitive.lib ? getty) then (sensitive.lib.getty pkgs_rev dots_rev) else ""}

Run 'dots-help' or 'nixos-help' for more information.'';
}

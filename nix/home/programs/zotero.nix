{ self, pkgs, ... }: {
  home.packages = [
    pkgs.zotero
    (import ./zotero_poll/zotero_poll.nix {inherit pkgs;})
  ];
  systemd.user.services.zotero =
    {
      Unit.Description = "Headless Zotero Instance";
      Install.WantedBy = [ "getty.target" ];
      Service = {
        ExecStart = "${pkgs.zotero}/bin/zotero --headless";
      };
    };
}

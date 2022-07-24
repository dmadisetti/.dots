# Nothing nice
{ inputs, ... }: {
  imports = [ ];
  programs.git = {
    inherit (inputs.sensitive.lib.git) enable;
    extraConfig = {
      user = {
        inherit (inputs.sensitive.lib.git) name email;
        signingKey = inputs.sensitive.lib.git.signing.key;
      };
      commit = { gpgSign = inputs.sensitive.lib.git.signing.enable; };
    };
    includes = [{ path = "${inputs.sensitive.lib.dots}/dot/gitconfig"; }];
  };
}

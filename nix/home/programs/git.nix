# Nothing nice
{ inputs, ... }: {
  imports = [ ];
  programs.git = {
    enable = inputs.sensitive.lib.git.enable;
    extraConfig = {
      user = {
        name = inputs.sensitive.lib.git.name;
        email = inputs.sensitive.lib.git.email;
        signingKey = inputs.sensitive.lib.git.signing.key;
      };
      commit = {
        gpgSign = inputs.sensitive.lib.git.signing.enable;
      };
    };
    includes = [{ path = "${inputs.sensitive.lib.dots}/dot/gitconfig"; }];
  };
}

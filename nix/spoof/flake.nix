# Fantastic Fake Flake For Fooling Flake tests‽
# 🥸 Should be valid nix, but also double as a mustache template.
{
  description = "{{user}}'s flake";

  inputs = { };

  outputs = inputs@{ self, ... }: {
    lib = {

      user = /*Default is dylan (hi) for testing reasons.{{#unless user}}*/ "dylan";
      #{{else}}*/ "{{user}}";{{/unless}}
      # Change this with `mkpasswd -m sha512crypt`.
      hashed = "{{hashed}}";
      # You can change this manually. Just sure make you manually move the folder.
      dots = "/home/{{user}}/.dots";

      default_wm = "{{default_wm}}";
      networking = /*Networking 📡📡📡{{#unless networking}}*/ { };
      #{{else}}*/{{{networking}}};{{/unless}}

      sshd = {
        enable = /*Disabled for live images.{{#if sshd}}*/ true;
        #{{else}}*/ false;{{/if}}
        port = /*{{#unless sshd_port}}*/ 22;
        #{{else}}*/ {{sshd_port}}; #{{/unless}}
      };
      keybase = {
        enable = /*Only relevant for live images.{{#if keybase}}*/ true;
        #{{else}}*/ false;{{/if}}
        username = "{{keybase_username}}";
        paper = ''{{{keybase_paper}}}'';
      };
      git = {
        enable = /*User particular information.{{#if git}}*/ true;
        #{{else}}*/ false;{{/if}}
        name = "{{git_name}}";
        email = "{{git_email}}";
        signing = {
          enable = /*Enforce signatures.{{#if git_signing}}*/ true;
          #{{else}}*/ false;{{/if}}
          key = "{{git_signing_key}}";
        };
      };
      certificates = [
        #{{{certificates}}}
      ];

      # Just a bunch of other stuff that is not as easily configurable.
      #{{#unless misc}}
      getty = pkgs_rev: dots_rev: ''
        ▄▄▄▄▄▄▄   ▄ ▄▄ ▄  ▄▄▄ ▄▄▄▄▄▄▄  Linux \r (\m)
        █ ▄▄▄ █ ▀ ▀ ▄█▀█▀   ▄ █ ▄▄▄ █  nixpkgs/${pkgs_rev}
        █ ███ █ ▀█▀ ▀ ▀ █▀ ▄▄ █ ███ █  dots/${dots_rev}
        █▄▄▄▄▄█ █▀▄▀█ ▄▀█▀█ █ █▄▄▄▄▄█  \d
        ▄▄▄▄▄ ▄▄▄█▀█  ▀▄▀▄▀█▀▄ ▄ ▄ ▄
        █▄▀██▀▄▄█ █ ▀██▄██▀▀██▀██▀▀▀▀
        ▀▄█▄ █▄▄▀▄▄ █▀▄ ▀▄█▄▀ ▀ ▀█▄▄▄
        ▀███ ▄▄█▄ ▄▄▄  ▄▀█▀▀▀ ▀▀█▀ ▀▀
        ██▀ ▀▀▄█▀ ██  ▀▀▀▄▀ █▀ █▀▀▄▄
        █▀▀ ▀█▄▀ ▀▄ ▀██▄█  ▀██ ▀▀██▀▀
        █ ▄█▀▄▄ ▄ ▀ █▀▄ ▀▄▀▀▄█▄█▄▄▄ ▄
        ▄▄▄▄▄▄▄ █▄ ▄▄  ▄▀ ▀██ ▄ █ █▀▀
        █ ▄▄▄ █ ▄ ██  ▀ ▀▄ ▀█▄▄▄█▀▄▀
        █ ███ █ █   ▀██▄▀▄███ ▄▄▄▄▄█▀
        █▄▄▄▄▄█ █ ▄ █▀▄▀ ▄ ▄▀█ █ ▀▄▀
      '';
      #{{else}}{{{misc}}}{{/unless}}
    };
  };
}

# Fantastic Fake Flake For Fooling Flake tests‽
# 🥸 Should be valid nix, but also double as a mustache template.
{
  description = "{{user}}'s flake";

  inputs = { };

  outputs = inputs@{ self, ... }: {
    lib = {

      user = /*Default is nixos.{{#unless user}}*/ "nixos";
      #{{else}}*/ "{{user}}";{{/unless}}
      hashed = "{{hashed}}";

      default_wm = "{{default_wm}}";
      networking = /*Networking 📡📡📡{{#unless networking}}*/ { };
      #{{else}}*/{{{networking}}};{{/unless}}

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

      pkgs = [
        #{{{pkgs}}}
      ];

      #{{{misc}}}
    };
  };
}

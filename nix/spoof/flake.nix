# Fantastic Fake Flake For Fooling Flake tests
# TODO: Maybe also make this a stub for templating?
{
  description = "fake flake for completeness";

  inputs = { };

  outputs = inputs@{ self, ... }: {
    lib = {
      user = "dylan";
      networking = {};
      certificates = [];
      hashed = "";
      paper = "";
    };
  };
}

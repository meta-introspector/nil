{
  # Just for tests. No need to be up-to-date.
  inputs.nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  inputs.nix = {
    flake = false;
    url = "github:meta-introspector/nix?ref=feature/CRQ-016-nixify";
  };
  inputs.non-flake-file = {
    flake = false;
    url = "https://raw.githubusercontent.com/NixOS/nix/7304806241fe4f72c5f33a5a929d675c8342fabd/flake.nix";
  };

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      forSystems = lib.genAttrs lib.systems.flakeExposed;
    in
    {
      packages = forSystems (system: {
        hello = derivation rec {
          pname = "hello";
          version = "1.2.3";
          name = "${pname}-${version}";

          inherit system;
          builder = "/bin/sh";
          args = ":";

          meta = {
            description = "A test derivation";
            homepage = "https://example.com";
            license = [
              lib.licenses.mit # OR
              lib.licenses.asl20
            ];
          };
        };
      });
    };
}

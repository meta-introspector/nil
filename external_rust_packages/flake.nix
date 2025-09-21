{
  description = "Aggregating flake for external Rust packages.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    nil.url = "path:../"; # Path to the nil flake
    nixpacks = { # Reference the nixpacks flake in the subdirectory
      url = "./nixpacks";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nil.follows = "nil"; # Ensure nil input is followed
    };
  };

  outputs = { self, nixpkgs, flake-utils, nil, nixpacks, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = {
          nixpacks = nixpacks.packages.${system}.default;
        };

        devShells = {
          nixpacks = nixpacks.devShells.${system}.default;
        };
      }
    );
}
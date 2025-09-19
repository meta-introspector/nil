{
  description = "Aggregating flake for external Rust packages.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    nixpacks = { # Reference the nixpacks flake in the subdirectory
      url = "./nixpacks";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nil.follows = "nil"; # Ensure nil input is followed
    };
  };

  outputs = { self, nixpkgs, flake-utils, nixpacks, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = {
          inherit (nixpacks.packages.${system}) default;
        };

        devShells = {
          inherit (nixpacks.devShells.${system}) default;
        };
      }
    );
}
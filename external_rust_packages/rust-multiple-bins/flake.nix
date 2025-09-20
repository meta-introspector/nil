{
  description = "Nix flake for building the rust-multiple-bins Rust project using nil's environment.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    nil.url = "path:../../"; # Path to the nil flake
    crate-src.url = "path:../../../nixpacks/examples/rust-multiple-bins"; # Path to the crate source
  };

  outputs = { self, nixpkgs, flake-utils, nil, crate-src, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        nilDevShell = nil.devShells.${system}.default;
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage rec {
          pname = "rust-multiple-bins";
          version = "0.1.0"; # Placeholder version

          src = crate-src;

          cargoLock = { # Replace with actual Cargo.lock path if available
            inherit (crate-src) src;
            output = "Cargo.lock";
          };

          nativeBuildInputs = with pkgs; [
            # Add other build inputs specific to this crate if necessary
          ];

          meta = with pkgs.lib;
            {
              description = "A Nix flake for the rust-multiple-bins Rust project";
              homepage = "https://github.com/your-org/rust-multiple-bins"; # Replace with actual homepage
              license = licenses.mit; # Replace with actual license
              platforms = platforms.linux;
            };
        };

        devShells.default = pkgs.mkShell {
          inherit (nilDevShell) packages;
          packages = nilDevShell.packages ++ (with pkgs; [
            # Add any additional development tools specific to this crate here
          ]);
          shellHook = ''
            ${nilDevShell.shellHook or ""}
            echo "Welcome to the rust-multiple-bins development shell!"
          '';
        };
      }
    );
}
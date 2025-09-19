{
  description = "Nix flake for building the nixpacks Rust project using nil's environment.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    nil.url = "path:../../"; # Path to the nil flake
    nixpacks-src.url = "path:/data/data/com.termux.nix/files/home/pick-up-nix2/nixpacks"; # Path to the nixpacks source
  };

  outputs = { self, nixpkgs, flake-utils, nil, nixpacks-src, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        nilDevShell = nil.devShells.${system}.default;
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage rec {
          pname = "nixpacks";
          version = "0.1.0"; # Replace with actual version if known

          src = nixpacks-src;

          cargoLock = { # Replace with actual Cargo.lock path if available
            inherit (nixpacks-src) src;
            output = "Cargo.lock";
          };

          # Inherit build inputs from nil's devShell if needed, or specify here
          nativeBuildInputs = with pkgs; [
            nilDevShell.packages # This might not be the correct way to inherit, adjust as needed
            # Add other build inputs specific to nixpacks if necessary
          ];

          # Add any runtime dependencies if necessary
          # buildInputs = with pkgs; [
          #   zlib
          # ];

          # Optional: Add checks if the project has tests
          # doCheck = true;

          meta = with pkgs.lib;
            {
              description = "A Nix flake for the nixpacks Rust project";
              homepage = "https://github.com/your-org/nixpacks"; # Replace with actual homepage
              license = licenses.mit; # Replace with actual license
              platforms = platforms.linux;
            };
        };

        devShells.default = pkgs.mkShell {
          inherit (nilDevShell) packages;
          packages = nilDevShell.packages ++ (with pkgs; [
            # Add any additional development tools specific to nixpacks here
          ]);
          shellHook = ''
            ${nilDevShell.shellHook or ""}
            echo "Welcome to the nixpacks development shell!"
          '';
        };
      }
    );
}
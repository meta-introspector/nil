{
  description = "A flake for the current task, providing a development shell.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    # Reference the parent project's docs and scripts directories
    docs.url = "path:../../../../docs";
    scripts.url = "path:../../../../scripts";
  };

  outputs = { self, nixpkgs, flake-utils, docs, scripts, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bash
            git
            shellcheck # For linting shell scripts
            # Add any other tools specific to this task here
          ];

          shellHook = ''
            echo "Welcome to the task-specific development shell!"
            echo "Docs are available at ${docs}"
            echo "Scripts are available at ${scripts}"
          '';
        };
      }
    );
}
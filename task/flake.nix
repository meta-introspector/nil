{
  description = "A flake for the current task, providing a development shell.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    # Reference the parent project's docs and scripts directories
    docs.url = "path:../../docs";
    scripts.url = "path:../../scripts";
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
            shellcheck # Add shellcheck for shell script linting
            # Add any other common tools needed for this specific task here
          ];

          shellHook = ''
            echo "Welcome to the development shell for the current task!"
            echo "Docs are available via the 'docs' input."
            echo "Scripts are available via the 'scripts' input."
          '';
        };
      }
    );
}
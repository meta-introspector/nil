# SOP-001: Applying the `nil` Flake to Rust Projects

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the process for integrating the `nil` (Nix Language Server) flake into other Rust-based projects and scripts within our monorepo. The goal is to standardize development environments, ensure reproducible builds, and provide consistent tooling for Rust development across projects by leveraging Nix flakes.

## 2. Scope

This SOP applies to:
*   All new and existing Rust projects within the monorepo that require a standardized development environment.
*   Scripts that interact with or depend on Rust projects, ensuring they operate within the defined Nix environment.

## 3. Prerequisites

Before proceeding, ensure the following:
*   Nix is installed on your system.
*   A basic understanding of Nix flakes and their structure.
*   The target Rust project has an existing `flake.nix` or is prepared to have one.
*   Familiarity with the monorepo's Nixification efforts documented in `~/nix2/docs/` and `scripts/`.

## 4. Procedure

### 4.1. Add `nil` as a Flake Input

In the target Rust project's `flake.nix`, add `nil` as an input. This assumes `nil` is available as a local path or a GitHub repository.

```nix
# <target-rust-project>/flake.nix
{
  description = "Nix flake for <Your Rust Project>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    # Add nil as an input
    nil.url = "path:../../vendor/nix/nil"; # Adjust path as necessary
    # Or if nil is a separate repo:
    # nil.url = "github:your-org/nil";
  };

  outputs = { self, nixpkgs, flake-utils, nil, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # ... rest of your outputs
      }
    );
}
```

### 4.2. Integrate `nil`'s Development Shell

Merge `nil`'s `devShell` into your project's `devShell`. This will bring in `nil`'s dependencies and tools.

```nix
# <target-rust-project>/flake.nix
{
  # ... (inputs as above)

  outputs = { self, nixpkgs, flake-utils, nil, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # Import nil's development shell
        nilDevShell = nil.devShells.${system}.default;
      in
      {
        devShells.default = pkgs.mkShell {
          # Inherit packages from nil's devShell
          inherit (nilDevShell) packages;

          # Add any project-specific packages
          packages = packages ++ (with pkgs; [
            rustc # Ensure Rust toolchain is present
            cargo
            # Add other Rust development tools like rust-analyzer, clippy, rustfmt
            # Or use nil's provided rust-analyzer if available
          ]);

          # Combine shell hooks
          shellHook = ''
            ${nilDevShell.shellHook or ""}
            echo "Welcome to the development shell for <Your Rust Project>!"
            # Add any project-specific shell initializations here
          '';
        };
      }
    );
}
```

### 4.3. Ensure Rust Toolchain Consistency

Verify that the Rust toolchain used by `nil` and your project are compatible. If `nil` provides a specific `rust-analyzer` or Rust toolchain, consider using it to maintain consistency.

### 4.4. Update `shellHook` for `nil`-specific Environment Variables

If `nil` requires specific environment variables or setup commands, ensure they are included in the `shellHook` of your project's `devShell`. The example above demonstrates how to combine shell hooks.

### 4.5. Test the New Development Environment

After modifying `flake.nix`, enter the development shell and verify that `nil` and other Rust tools are correctly configured.

```bash
nix develop
```

## 5. Verification

*   **Enter the development shell:** `nix develop`
*   **Check `nil` functionality:**
    *   Verify that `nil` is available and working (e.g., by opening a Rust file in an editor configured with LSP and checking for `nil` diagnostics).
    *   Run `nil --version` if `nil` is exposed as a command.
*   **Check Rust toolchain:**
    *   `rustc --version`
    *   `cargo --version`
*   **Build the project:** `cargo build`
*   **Run tests:** `cargo test`

## 6. Troubleshooting

*   **`nil` not found:** Ensure the `nil` input path is correct in `flake.nix` and that `nil.devShells.${system}.default` is correctly inherited.
*   **Conflicting packages:** If there are conflicts between `nil`'s packages and your project's packages, you might need to explicitly select or override specific packages.
*   **Nix build errors:** Check the Nix build logs for detailed error messages.
*   **`flake.lock` issues:** Run `nix flake update` to update inputs and resolve dependencies.

## 7. References

*   `~/nix2/docs/`: General documentation on Nixification efforts.
*   `scripts/`: Automation scripts related to Nix and submodules.
*   `nil` project documentation (if available).

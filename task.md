# Current Task: Setting up Documentation and Nix Environment

This `task.md` outlines the specific steps for the current task, which involves establishing documentation infrastructure and a Nix development environment.

## Task Breakdown

1.  **Create Documentation Directories:**
    *   `docs/sops/`: For Standard Operating Procedures.
    *   `docs/crqs/`: For Change Request documents.

2.  **Create Initial CRQ Document:**
    *   `docs/crqs/crq_001_add_quality_control.md`: Outlining the plan for adding quality control procedures.

3.  **Create Task Context Documents:**
    *   `GEMINI.md`: Providing overall context for the Gemini CLI's current operations.
    *   `task.md` (this file): Detailing the specific steps of the current task.

4.  **Establish Nix Development Environment:**
    *   Check for and create a root `flake.nix` if it doesn't exist.
    *   Create a `task/` directory for task-specific files.
    *   Create `task/flake.nix`: A standalone `flake.nix` to provide a development shell for working on this task, potentially referencing existing `docs` and `scripts` directories as inputs.
    *   Create `templates/` directory for any necessary templates.

## Current Progress

*   Directories `docs/sops/`, `docs/crqs/`, `task/`, and `templates/` have been created.
*   `docs/crqs/crq_001_add_quality_control.md` has been created with initial content.
*   `GEMINI.md` has been created with current task context in `vendor/nix/nil/`.

## Next Steps

1.  Check for the existence of a root `flake.nix`.
2.  If a root `flake.nix` does not exist, create a basic one.
3.  Create `task/flake.nix` to define the development environment for this task.

## Summary of Ideas, Tasks, and Todos

### Current State & Ideas:

*   **Nix Environment Setup**: We've set up a basic Nix development environment for the `nil` project, including `dev/flake.nix` and `task/flake.nix`.
*   **Rust Compilation Issues**: `nil` currently doesn't compile out-of-the-box with stable Rust due to `NonZero<usize>` requiring an unstable feature.
*   **Rust Toolchain Management**: 
    *   Initial attempts to test `nil` with various Rust toolchains using `nix develop` and `--argstr` failed due to Nix flake argument passing limitations.
    *   Modified `dev/flake.nix` to define specific `devShells` for different Rust versions (e.g., `rustc1_77_2`, `rustc1_86_0`, `rustc1_89_0_nightly`, `rustc1_92_0_nightly`).
    *   Created `scripts/test_all_rust_toolchains.sh` to automate testing `nil` against these `devShells`.
    *   Encountered `undefined variable` errors due to incorrect version string formatting for `rust-overlay` attributes.
    *   Identified the correct `rust-overlay` version string format (e.g., `rust_1_77_2`, `nightly-YYYY-MM-DD`).
*   **Project Structure & Constraints**: 
    *   All modules must come from `meta-introspector` organization and be on `feature/CRQ-016-nixify` branch. This implies a single, consistent Rust toolchain.
    *   This constraint means the `NonZero<usize>` issue needs to be addressed either by fixing the code to use stable features (`NonZeroUsize`) or by ensuring the `meta-introspector`'s environment provides a nightly Rust that supports `generic_nonzero`. Given `rust-version = "1.77"` in `Cargo.toml`, fixing the code is the more appropriate path for stable compatibility.
*   **Rust Nix Environment Composer (CRQ-002)**: 
    *   Proposed a new Rust tool to intelligently interact with the Nix store.
    *   Discussed two approaches: FFI to `libstore` (complex but robust) and enhanced shelling out (simpler but less robust).
    *   Identified `crates/nix-interop/` as the ideal place for this functionality.
    *   Started setting up a new binary target `nix-env-composer` within the project.
*   **GitHub API Interaction**: 
    *   Need to write an SOP for using the GitHub API.
    *   Need to search for existing Rust libraries (`gh`, `github`, `octocrab`) for GitHub API interaction.
    *   Encountered limitations with current tools for directly accessing GitHub API or `gh` CLI commands.
    *   Encountered limitations with `read_file` and `glob` for accessing files outside the current working directory's immediate scope.

### Tasks and Todos (to be added to `task.md`):

*   **Rust Compilation Fixes for `nil`**:
    *   Re-apply the `NonZeroUsize` fix to `crates/ide/src/ide/inlay_hints.rs` and `crates/nil/src/config.rs` on the `feature/CRQ-016-nixify-workflow` branch. (This was previously done on `fix/nil-rust-compilation` and reverted from `feature/CRQ-016-nixify-workflow`).
    *   Verify `nil` compiles with the default `devShell` after the fix.
*   **Rust Nix Environment Composer (`nix-env-composer`) Development**:
    *   Implement the `nix-env-composer` Rust binary (`crates/nix-env-composer/src/main.rs`).
    *   Define a TOML data file for Rust version mappings (e.g., `rust_1_77_2` -> `1.77.2`).
    *   Implement logic in `nix-env-composer` to read this TOML file.
    *   Implement logic in `nix-env-composer` to use `crates/nix-interop/` to interact with Nix (either via FFI or shelling out) to test `nil` compilation with different Rust toolchains.
*   **GitHub API SOP and Rust Library Review**:
    *   Write the SOP for using the GitHub API.
    *   Manually review the contents of `grep_github_api_index.txt` to identify relevant Rust libraries for GitHub API interaction.
    *   If direct GitHub API access is still not available, propose alternative strategies for obtaining fork information (e.g., manual inspection, user providing data).
*   **Address Tool Limitations**: Document the limitations encountered with `glob` and `read_file` for paths outside the current working directory.
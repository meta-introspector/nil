# CRQ-002: Rust Nix Environment Composer

## 1. Introduction

This Change Request (CRQ) proposes the development of a new Rust-based tool, the "Rust Nix Environment Composer." The primary goal of this tool is to intelligently read and interact with the Nix store to compose and manage Nix development environments. This will provide a more programmatic and integrated approach to Nix environment management within Rust projects, leveraging the type safety and performance benefits of Rust.

## 2. Problem Statement

Currently, interacting with the Nix store from Rust typically involves shelling out to `nix` command-line utilities and parsing their output. While functional, this approach is:

*   **Fragile**: Dependent on the stability of `nix` command-line output, which can change.
*   **Inefficient**: Involves process overhead and string parsing.
*   **Limited**: Does not provide direct programmatic access to Nix store internals.

There is a need for a more robust, efficient, and idiomatic Rust solution for interacting with the Nix store, especially for tasks like identifying available Rust toolchains, managing dependencies, and composing complex development shells.

## 3. Proposed Solution

Develop a Rust tool, potentially as an extension to the existing `nix-interop` crate, that provides intelligent interaction with the Nix store. Two primary approaches will be investigated:

### 3.1. Approach A: Foreign Function Interface (FFI) to `libstore`

This approach involves creating Rust bindings to the C++ `libstore` library, which is the core component of Nix responsible for managing the Nix store. This would provide the most direct and robust programmatic access to Nix store functionalities.

*   **Pros**: High performance, direct access to Nix internals, less fragile.
*   **Cons**: High complexity, requires managing C++ FFI, potential for ABI instability with `libstore` updates.
*   **Implementation Details**: Utilize `bindgen` to generate Rust FFI bindings for relevant `libstore` functions. Focus on functions for querying store paths, identifying derivations, and managing garbage collection roots.

### 3.2. Approach B: Enhanced Shelling Out with Structured Output

This approach would involve executing `nix` commands but with a focus on utilizing structured output formats (e.g., JSON) where available, and robust parsing of such output. This would be a more incremental improvement over the current ad-hoc shelling out.

*   **Pros**: Lower complexity, quicker to implement.
*   **Cons**: Still dependent on `nix` command-line interface, potentially less performant than FFI, structured output is not available for all `nix` commands.
*   **Implementation Details**: Use Rust's `std::process::Command` to execute `nix` commands. Parse JSON output using `serde` where available. Implement robust error handling and fallback mechanisms.

## 4. Scope

The initial scope of this CRQ will focus on:

*   **Nix Store Path Discovery**: Identifying and listing Nix store paths, particularly for Rust toolchains. This will involve programmatic discovery of `rustc` executables within the `/nix/store`.
*   **Derivation Inspection**: Reading basic information about derivations (e.g., inputs, outputs).
*   **Environment Composition**: Providing utilities to construct and activate Nix development shells programmatically.
*   **Toolchain Testing**: Developing a mechanism to test the compilation and functionality of Rust projects against various discovered Rust toolchains.

## 5. Success Criteria

*   A Rust library (e.g., `nix-interop` extension or a new crate) capable of querying Nix store paths and derivation information.
*   A command-line interface (CLI) tool demonstrating the capabilities of the library, such as listing available Rust toolchains and their versions.
*   Integration with existing `flake.nix` files to allow dynamic selection of Rust toolchains for `nil` and other Rust projects.
*   A "battery of tests" script (or Rust equivalent) that can iterate through identified Rust toolchains and attempt to build/test a target Rust project, reporting success or failure.

## 6. Future Work

*   More advanced Nix store manipulation (e.g., garbage collection management, path registration).
*   Integration with other Nix features (e.g., flakes, overlays).
*   Support for cross-compilation scenarios.

## 7. Estimated Effort

*   **Approach A (FFI)**: High (2-4 weeks for initial bindings and basic functionality).
*   **Approach B (Enhanced Shelling Out)**: Medium (1-2 weeks for initial functionality).

Further estimation will be provided after initial research into `libstore` FFI possibilities.

## 8. Tasks and Todos

### 8.1. Toolchain Discovery

*   **Task**: Implement a Rust function to discover all `rustc` executables in the Nix store.
    *   **Todo**: Refine the `find` command (or its Rust equivalent) to accurately locate `bin/rustc` within store paths.
    *   **Todo**: Extract version information from the discovered `rustc` paths.
*   **Task**: Integrate the `scripts/extract_suffixes.sh` (or a Rust equivalent) to identify file types and potentially filter relevant store paths.

### 8.2. Test Harness Development

*   **Task**: Create a Rust-based test harness that can:
    *   Take a target Rust project (e.g., `nil`).
    *   Accept a `rustc` executable path.
    *   Attempt to build and test the project using the specified `rustc`.
    *   Capture and report the build/test results (success/failure, output, errors).
*   **Task**: Develop a mechanism to dynamically override the `rustc` used by a Rust project's `flake.nix` for testing purposes.

### 8.3. Reporting and Analysis

*   **Task**: Implement reporting functionality to summarize the results of the toolchain tests.
    *   **Todo**: Clearly indicate which Rust toolchains successfully built the project and which failed.
    *   **Todo**: Provide details on failures (e.g., compilation errors, test failures).
*   **Task**: (Future) Develop a mechanism to "uninstall" (i.e., identify for removal) non-working toolchains, acknowledging that actual Nix store garbage collection is a separate process.
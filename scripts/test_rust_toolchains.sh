#!/usr/bin/env bash

# This script tests nil compilation with various Rust toolchains using Nix.

# List of Rust versions to test
RUST_VERSIONS=(
  "1.77.2"
  "1.86.0"
  "1.89.0-nightly-2025-06-01"
  "1.92.0-nightly-2025-09-16"
)

RESULTS_FILE="rust_toolchain_test_results.txt"
> "$RESULTS_FILE" # Clear previous results

echo "Starting Rust toolchain compatibility tests for nil..." | tee -a "$RESULTS_FILE"
echo "-----------------------------------------------------" | tee -a "$RESULTS_FILE"

for version in "${RUST_VERSIONS[@]}"; do
  echo "Testing with Rust version: $version" | tee -a "$RESULTS_FILE"
  echo "-----------------------------------" | tee -a "$RESULTS_FILE"

  # Use nix develop to enter the dev shell with the specified rustcVersion
  # and then run cargo build -p nil
  # Map version string to devShell name
  DEV_SHELL_NAME=""
  case "$version" in
    "1.77.2") DEV_SHELL_NAME="rustc1_77_2" ;;
    "1.86.0") DEV_SHELL_NAME="rustc1_86_0" ;;
    "1.89.0-nightly-2025-06-01") DEV_SHELL_NAME="rustc1_89_0_nightly" ;;
    "1.92.0-nightly-2025-09-16") DEV_SHELL_NAME="rustc1_92_0_nightly" ;;
    *) echo "Error: Unknown Rust version $version"; continue ;;
  esac

  if nix develop "./dev#$DEV_SHELL_NAME" --command cargo build -p nil; then
    echo "SUCCESS: nil compiled with Rust version $version" | tee -a "$RESULTS_FILE"
  else
    echo "FAILURE: nil failed to compile with Rust version $version" | tee -a "$RESULTS_FILE"
  fi
  echo "" | tee -a "$RESULTS_FILE"
done

echo "-----------------------------------------------------" | tee -a "$RESULTS_FILE"
echo "All tests completed. Results saved to $RESULTS_FILE" | tee -a "$RESULTS_FILE"

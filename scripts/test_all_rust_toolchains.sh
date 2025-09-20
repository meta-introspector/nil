#!/usr/bin/env bash

# This script scans ~/nix2/index/sizes.txt for Rust toolchain versions,
# tests nil compilation with each, and reports the results.

set -euo pipefail

SIZES_FILE="/data/data/com.termux.nix/files/home/pick-up-nix2/index/sizes.txt"
RESULTS_FILE="rust_toolchain_test_results_all.txt"
true > "$RESULTS_FILE" # Clear previous results

echo "Scanning $SIZES_FILE for Rust toolchain versions..." | tee -a "$RESULTS_FILE"
echo "-----------------------------------------------------" | tee -a "$RESULTS_FILE"

# Extract Rust versions and format them for rust-overlay
# This regex captures stable versions (e.g., 1.77.2) and nightly versions (e.g., 1.92.0-nightly-2025-09-16)
# It then transforms them into the format expected by rust-overlay (e.g., 1_77_2 or nightly-2025-09-16)
mapfile -t RUST_VERSIONS < <(
  grep -oP 'rustc-\K[0-9]+\.[0-9]+\.[0-9]+(-nightly-[0-9]{4}-[0-9]{2}-[0-9]{2})?' "$SIZES_FILE" | \
  sort -u | while read -r version; do
    if [[ "$version" == *"-nightly-"* ]]; then
      # Extract date for nightly versions and prepend "rust-nightly_"
      echo "$version" | sed -E 's/.*(nightly-[0-9]{4}-[0-9]{2}-[0-9]{2})/rust-nightly_\1/'
    else
      # Replace dots with underscores for stable versions and prepend "rust_"
      echo "$version" | tr '.' '_' | sed 's/^/rust_/'
    fi
  done
)

if [ ${#RUST_VERSIONS[@]} -eq 0 ]; then
  echo "No Rust versions found in $SIZES_FILE. Exiting." | tee -a "$RESULTS_FILE"
  exit 0
fi

echo "Found Rust versions to test: ${RUST_VERSIONS[*]}" | tee -a "$RESULTS_FILE"
echo "" | tee -a "$RESULTS_FILE"

echo "Starting Rust toolchain compatibility tests for nil..." | tee -a "$RESULTS_FILE"
echo "-----------------------------------------------------" | tee -a "$RESULTS_FILE"

for version in "${RUST_VERSIONS[@]}"; do
  echo "Testing with Rust version: $version" | tee -a "$RESULTS_FILE"
  echo "-----------------------------------" | tee -a "$RESULTS_FILE"

  # Use nix develop to enter the dev shell with the specified rustcVersion
  # and then run cargo build -p nil
  if nix develop ./dev#default --arg rustcVersion "$version" --command cargo build -p nil; then
    echo "SUCCESS: nil compiled with Rust version $version" | tee -a "$RESULTS_FILE"
  else
    echo "FAILURE: nil failed to compile with Rust version $version" | tee -a "$RESULTS_FILE"
  fi
  echo "" | tee -a "$RESULTS_FILE"
done

echo "-----------------------------------------------------" | tee -a "$RESULTS_FILE"
echo "All tests completed. Results saved to $RESULTS_FILE" | tee -a "$RESULTS_FILE"

# Run shellcheck on the script itself
echo "Running shellcheck on this script..." | tee -a "$RESULTS_FILE"
shellcheck "$0" | tee -a "$RESULTS_FILE"

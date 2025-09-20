#!/usr/bin/env bash

# scripts/lint_and_test_external_crates.sh
# Lints and tests all external Rust crates defined in external_rust_packages/.

EXTERNAL_PACKAGES_DIR="external_rust_packages"
LOG_SCRIPT="scripts/run_and_log.sh"

if [ ! -d "$EXTERNAL_PACKAGES_DIR" ]; then
  echo "Error: External packages directory not found at $EXTERNAL_PACKAGES_DIR"
  exit 1
fi

if [ ! -f "$LOG_SCRIPT" ]; then
  echo "Error: Logging script not found at $LOG_SCRIPT"
  exit 1
fi

# Ensure the logging script is executable
chmod +x "$LOG_SCRIPT"

echo "Starting linting and testing of external Rust crates..."

for CRATE_DIR in "$EXTERNAL_PACKAGES_DIR"/*;
do
  if [ -d "$CRATE_DIR" ]; then
    CRATE_NAME=$(basename "$CRATE_DIR")
    echo "\n--- Processing crate: $CRATE_NAME ---"

    # Lint with cargo clippy
    echo "Running cargo clippy for $CRATE_NAME..."
    "$LOG_SCRIPT" "nix develop ./$EXTERNAL_PACKAGES_DIR#$CRATE_NAME --command bash -c 'cargo clippy --all-targets -- -D warnings'" || echo "Clippy failed for $CRATE_NAME"

    # Run cargo test
    echo "Running cargo test for $CRATE_NAME..."
    "$LOG_SCRIPT" "nix develop ./$EXTERNAL_PACKAGES_DIR#$CRATE_NAME --command bash -c 'cargo test'" || echo "Tests failed for $CRATE_NAME"

    echo "--- Finished processing crate: $CRATE_NAME ---"
  fi
done

echo "\nLinting and testing process complete."

#!/usr/bin/env bash

# scripts/extract_cargo_tomls.sh
# Extracts paths to Cargo.toml files from a given list.

INPUT_FILE="/data/data/com.termux.nix/files/home/nix2/index/file_toml.txt"

if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: Input file not found at $INPUT_FILE"
  exit 1
fi

echo "Extracting Cargo.toml paths from $INPUT_FILE:"

grep "Cargo.toml$" "$INPUT_FILE"

#!/usr/bin/env bash

# This script extracts unique file extensions (suffixes) from a list of filenames.
# It can read from standard input or from command-line arguments.

if [[ -t 0 ]]; then
  # If stdin is a TTY, read from arguments
  filenames=("$@")
else
  # Otherwise, read from stdin
  readarray -t filenames
fi

declare -A suffixes_map

for filename in "${filenames[@]}"; do
  # Extract the extension
  extension="${filename##*.}"
  # If the filename does not contain a dot, or the dot is the first character (e.g., ".bashrc"),
  # then it might not have a "true" extension in the conventional sense.
  # We'll consider it an extension if it's not the whole filename and contains a dot.
  if [[ "$filename" == *.* && "$extension" != "$filename" ]]; then
    suffixes_map["$extension"]=1
  fi
done

# Print unique suffixes, sorted
for suffix in "${!suffixes_map[@]}"; do
  echo "$suffix"
done | sort -u

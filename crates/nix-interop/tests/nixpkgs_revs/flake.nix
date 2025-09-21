{
  # Just for tests. No need to be up-to-date.
  inputs = {
    nixos-unstable.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    nixos-22-11.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    nixos-23-05.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  };

  outputs = inputs: { };
}

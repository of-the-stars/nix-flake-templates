# This template automatically sets up a development environment to automatically build and flash
#   a rust program to any avr chip, specifically for the Arduino Uno. Simply write, save,and run
#   `cargo run` to flash the chip.

{
  description = "of-the-star's custom arduino development flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    naersk.url = "github:nix-community/naersk/master";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      naersk,
      rust-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          # Configure the system for cross compilation
          crossSystem = {
            # Tells nixpkgs the target system
            config = "avr";
            # Tells rust the target system
            rustc.config = "avr-none";
          };
          overlays = [ (import rust-overlay) ];
        };

        # Builds the rust components from the toolchain file
        toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

        # Tells nix which rust components to use to build the package
        naersk-package = pkgs.callPackage naersk {
          cargo = toolchain;
          rustc = toolchain;
          clippy = toolchain;
        };
      in
      {
        devShells.default =
          with pkgs;
          # Use the pkgsCross.avr version of mkShell to let nix pick which systems to use
          pkgs.pkgsCross.avr.mkShell {
            buildInputs = [
              avrlibc
            ];

            nativeBuildInputs = [
              rustup
              avrdude
              cargo
              cargo-info
              clippy
              just
              pkgsCross.avr.buildPackages.binutils
              pkgsCross.avr.buildPackages.gcc
              ravedude
              rust-analyzer
              rustc
              rustfmt
            ];

            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

            shellHook = '''';
          };

        packages.default = naersk-package.buildPackage ./.;
      }
    );
}

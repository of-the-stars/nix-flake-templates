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
          crossSystem = {
            config = "avr-none";
          };
          overlays = [ (import rust-overlay) ];
        };

        toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

        naersk-package = pkgs.callPackage naersk {
          cargo = toolchain;
          rustc = toolchain;
          clippy = toolchain;
        };
      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            buildInputs = [
              avrlibc
            ];

            nativeBuildInputs = [
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

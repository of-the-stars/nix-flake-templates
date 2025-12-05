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
    ravedude.url = "github:Rahix/avr-hal?dir=ravedude";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      naersk,
      rust-overlay,
      ravedude,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
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
        devShell =
          with pkgs;
          mkShell {
            buildInputs = [
              cargo
              cargo-info
              clippy
              just
              rust-analyzer
              rustc
              rustfmt

              avrdude
              avrlibc
              pkgsCross.avr.buildPackages.binutils
              pkgsCross.avr.buildPackages.gcc
              ravedude.packages."${system}".default
            ];

            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

            shellHook = '''';
          };

        packages.default = naersk-package.buildPackage ./.;
      }
    );
}

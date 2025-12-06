{
  description = "of-the-star's custom rust development flake";

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
          mkShell {
            buildInputs = [
              rustup
              cargo
              cargo-info
              clippy
              just
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

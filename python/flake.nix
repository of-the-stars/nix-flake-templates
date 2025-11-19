{
  description = "A very basic, somehow still opinionated, flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        # TODO: Change package name
        name = "foo";
        src = ./.;
      in
      {
        devShell =
          with pkgs;
          mkShell {
            buildInputs = [
              python3Packages.python
              python3Packages.venvShellHook
            ];
            venvDir = "./.venv";
          };

        packages.default = derivation {
          inherit system name src;
          # TODO: Add package build step
          builder = with pkgs; "${bash}/bin/bash";
          args = [
            "-c"
            "echo Building! > $out"
          ];
        };
      }
    );
}

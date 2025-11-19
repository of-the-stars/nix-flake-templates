{
  description = "A basic flake for dev environments and packaging";

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
              # TODO: Place development dependencies in here
              # package managers, build tools, debuggers, etc

              # for example
              gnumake # this is a build tool, you just add the package name
            ];
          };

        packages.default = derivation {
          inherit system name src;
          # TODO: Add package build step
          builder = with pkgs; "${bash}/bin/bash";
          args = [
            "-c"
            "echo foo > $out"
          ];
        };
      }
    );
}

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
        pname = "foo";
        src = ./.;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # TODO: Place development dependencies in here
            # package managers, build tools, debuggers, etc

            # for example
            gnumake # this is a build tool, you just add the package name
          ];

          # Run whatever commands you'd like when entering the shell
          shellHook = ''
            echo "Entering nix shell!!";
          '';
        };

        packages.default = derivation {
          inherit system pname src;
          # TODO: Add package build step
          builder = with pkgs; "${bash}/bin/bash";
          args = [
            "-c"
            "echo foo > $out"
          ];
        };

        formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
      }
    );
}

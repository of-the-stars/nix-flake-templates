{
  description = "A collection of of-the-star's opinionated nix flake templates";

  outputs =
    {
      self,
    }:
    {
      templates = {
        default = {
          path = ./default;
          description = "A basic flake for development environments and packaging";
        };

        rust = {
          path = ./rust;
          description = "A rust development flake that adds the necessary tooling and development environment for excellent automation";
        };

        python = {
          path = ./python;
          description = "A python development flake";
        };
      };
    };
}

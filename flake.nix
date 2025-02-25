{
  description = "rspec.nvim";

  inputs = {
    nixpkgs.url = "nixpkgs";
    fu.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, fu, ... }:
    with fu.lib;
    eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells = rec {
          default = test-shell;
          test-shell = import ./shell.nix { inherit pkgs; };
        };
      }
    );
}

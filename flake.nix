{
  description = "A collection of presets for pre-commit-hooks.nix";

  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.pre-commit-hooks = {
    url = "github:cachix/pre-commit-hooks.nix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , pre-commit-hooks
    }:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs { inherit system; };

        run = hooks: pre-commit-hooks.lib.${system}.run {
          src = ./.;
          inherit hooks;
        };

        checks = {
          default = {
            nixpkgs-fmt.enable = true;
            nix-linter.enable = false;
          };
        };
      in
      rec {
        devShell = pkgs.mkShell {
          inherit (run checks.default) shellHook;
        };
      });
}

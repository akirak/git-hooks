{
  description = "A collection of presets for pre-commit-hooks.nix";

  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.pre-commit-hooks = {
    url = "github:cachix/pre-commit-hooks.nix/50cfce93606c020b9e69dce24f039b39c34a4c2d";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
  };
  inputs.flake-no-path = {
    url = "github:akirak/flake-no-path";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , pre-commit-hooks
    , ...
    } @ inputs:
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
            flake-no-path = {
              enable = true;
              name = "Ensure that flake.lock does not contain a local path";
              entry = "${
                inputs.flake-no-path.packages.${system}.flake-no-path
              }/bin/flake-no-path";
              files = "flake\.lock$";
              pass_filenames = true;
            };
          };
        };
      in
      rec {
        devShell = pkgs.mkShell {
          inherit (run checks.default) shellHook;
        };
      });
}

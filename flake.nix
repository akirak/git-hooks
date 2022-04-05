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
  inputs.flake-no-path = {
    url = "github:akirak/flake-no-path";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
    inputs.pre-commit-hooks.follows = "pre-commit-hooks";
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

        checks = nixpkgs.lib.fix (checks: {
          default = {
            alejandra.enable = true;
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
          deno = checks.default // {
            deno-fmt = {
              enable = true;
              name = "Reformat deno code";
              entry = "${pkgs.deno}/bin/deno fmt";
              files = "\\.(t|j)sx?$";
              pass_filenames = true;
            };
            deno-lint = {
              enable = true;
              name = "Lint deno code";
              entry = "${pkgs.deno}/bin/deno lint";
              files = "\\.(t|j)sx?$";
              pass_filenames = true;
            };
          };
        });
      in
      rec {
        devShell = pkgs.mkShell {
          inherit (run checks.default) shellHook;
        };
        devShells.deno = pkgs.mkShell {
          inherit (run checks.deno) shellHook;
        };
      });
}

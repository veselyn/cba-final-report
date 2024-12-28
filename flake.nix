{
  description = "cba-final-report";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix/main";
    devenv.url = "github:cachix/devenv/main";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      imports = [
        inputs.devenv.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      perSystem = {
        config,
        pkgs,
        ...
      }: let
        texlive = pkgs.texlive.combined.scheme-full;
      in {
        treefmt.config = {
          projectRootFile = "flake.nix";

          programs.alejandra.enable = true;
          programs.prettier.enable = true;
          programs.prettier.excludes = ["CHANGELOG.md"];

          settings.formatter.tex-fmt = {
            command = "${pkgs.tex-fmt}/bin/tex-fmt";
            options = ["--usetabs"];
            includes = ["*.tex"];
          };
        };

        devenv.shells.default = {
          packages = [
            config.treefmt.build.wrapper
            texlive
          ];

          pre-commit.hooks = {
            treefmt.enable = true;
            treefmt.package = config.treefmt.build.wrapper;
          };
        };

        packages.build-report = pkgs.writeShellApplication {
          name = "build-report";
          runtimeInputs = [
            texlive
            pkgs.coreutils
            pkgs.git
          ];
          text = ''
            root=$(git rev-parse --show-toplevel)
            cd "$root"

            mkdir -p build

            latexmk -xelatex main
            mv main.pdf build/Final-Project-Report.pdf
          '';
        };
      };
    };
}

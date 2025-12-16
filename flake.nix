{
  description = "A Nix-flake-based R development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  inputs.rNvim = {
    url = "github:R-nvim/R.nvim";
    flake = false;
  };

  outputs =
    { self, ... }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowBroken = true;
              overlays = [ inputs.self.overlays.default ];
            };
          }
        );
    in
    {
      overlays.default = final: prev: rec {
        # Build nvimcom manually from R.nvim source
        nvimcom = final.rPackages.buildRPackage {
          name = "nvimcom";
          src = inputs.rNvim;
          sourceRoot = "source/nvimcom";

          buildInputs = with final; [
            R
            gcc
            gnumake
          ];

          meta = {
            description = "R.nvim communication package";
            homepage = "https://github.com/R-nvim/R.nvim";
            maintainers = [ ];
          };
        };

        eemR = final.rPackages.buildRPackage {
          name = "eemR";
          src = ./.;
          # optional:
          propagatedBuildInputs = with final.rPackages; [
            MBA
            R_matlab
            assertthat
            dplyr
            ggplot2
            plot3D
            pracma
            purrr
            rlist
            stringr
            tidyr
            viridis
          ];
        };

        # Shared R package list for both wrappers
        rPackageList = with final.rPackages; [
          cli
          cyclocomp
          devtools
          eemR
          fs
          httpgd
          languageserver
          lintr
          nvimcom
          quarto
        ];

        # Create rWrapper with packages (for LSP and R.nvim)
        wrappedR = final.rWrapper.override { packages = rPackageList; };

        # Create radianWrapper with same packages (for interactive use)
        wrappedRadian = final.radianWrapper.override { packages = rPackageList; };
      };

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              wrappedR # R with packages for LSP
              wrappedRadian # radian with packages for interactive use
              glibcLocales # Locale support for proper UTF-8 handling
              quarto
            ];

            shellHook = ''
              export LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive"
              export LC_ALL="en_US.UTF-8"
            '';
          };
        }
      );

      templates = {
        default = {
          path = ./.;
          description = "R development environment with nvimcom and R.nvim integration";
          welcomeText = ''
            # R Nix Development Environment

            ## Getting started
            - Run `direnv allow` to activate the environment (if using direnv)
            - Customize R packages in flake.nix rPackageList
            - Enter the shell with `nix develop`

            ## What's included
            - R with languageserver, nvimcom, lintr, fs, and cli
            - radian (modern R console)
            - Configured for R.nvim integration
            - Pre-configured .lintr file with opinionated linting rules
          '';
        };
      };
    };
}

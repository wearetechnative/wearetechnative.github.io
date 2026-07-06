{
  description = "wearetechnative open-source portfolio site — hermetic Hugo build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs }:
    let
      # Plain-nix multi-arch support — no flake-utils.
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # Apply a function for every supported system, keyed by system name.
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems
          (system: f {
            inherit system;
            pkgs = import nixpkgs { inherit system; };
          });
    in
    {
      # Development shell: everything the build and verify steps need, pinned.
      devShells = forAllSystems ({ pkgs, ... }: {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            hugo        # extended build by default in nixpkgs
            curl
            jq
            nodejs
            playwright-driver.browsers
            lychee
            just
            yq-go       # curation.yaml handling in the merge/fetch scripts
          ];

          # Point Playwright at the Nix-provided browsers; skip its own download.
          env = {
            PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
            PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
          };

          shellHook = ''
            echo "wearetechnative.github.io devShell — hugo $(hugo version | cut -d' ' -f2)"
          '';
        };
      });

      # The built site. Uses a placeholder data/repos.json so `nix build` is
      # reproducible offline; the real grid comes from `just fetch` before
      # `just build` (or the CI fetch step). See design.md for hugo-scaffold-brand.
      packages = forAllSystems ({ pkgs, ... }: {
        default = pkgs.stdenvNoCC.mkDerivation {
          pname = "wearetechnative-portfolio-site";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [ pkgs.hugo ];
          buildPhase = ''
            runHook preBuild
            # Ensure a data file exists so Hugo builds without a network fetch.
            [ -f data/repos.json ] || { mkdir -p data; echo '[]' > data/repos.json; }
            hugo --minify --gc --destination "$out"
            runHook postBuild
          '';
          installPhase = "true"; # hugo already wrote to $out
          dontFixup = true;
        };
      });

      # `nix flake check` runs this on each system.
      formatter = forAllSystems ({ pkgs, ... }: pkgs.nixpkgs-fmt);
    };
}

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

      # `nix flake check` runs this on each system. The site build itself
      # (packages.default) is added by the Hugo-scaffold epic; keep a formatter
      # check here so the flake is valid and checkable from day one.
      formatter = forAllSystems ({ pkgs, ... }: pkgs.nixpkgs-fmt);
    };
}

## 1. Flake foundation

- [x] 1.1 Write `flake.nix` with a single `nixpkgs` input (no flake-utils).
- [x] 1.2 Implement `forAllSystems` over `["x86_64-linux","aarch64-linux","x86_64-darwin","aarch64-darwin"]`.
- [x] 1.3 Define the devShell packages: hugo (extended), curl, jq, nodejs, playwright-driver.browsers, lychee, just, yq-go.
- [x] 1.4 Export `PLAYWRIGHT_BROWSERS_PATH` and `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1`.
- [x] 1.5 Add a `formatter` output (`nixpkgs-fmt`) so `nix flake check` has a check.
- [x] 1.6 Generate and commit `flake.lock`.

## 2. Command surface & VCS hygiene

- [x] 2.1 Add `.envrc` with `use flake` for direnv.
- [x] 2.2 Add `justfile` with `dev`, `build`, `fetch`, `verify` targets wrapping `nix develop -c ...`.
- [x] 2.3 Add `.gitignore` covering `public/`, `data/repos.json`, node/Playwright, and Nix artifacts.

## 3. Verification

- [x] 3.1 `nix flake check` passes.
- [x] 3.2 `nix develop -c` resolves hugo/jq/just/lychee/node/yq (versions printed).
- [x] 3.3 `just --list` shows dev, build, fetch, verify targets.

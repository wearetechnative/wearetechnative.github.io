## Context

Brief §2.3 requires a hermetic build: `nix develop -c hugo --minify` with zero
errors and a passing `nix flake check`, no global toolchain. Pim additionally
mandates plain nix over flake-utils and explicit multi-architecture support. This
change lands that foundation before any other epic starts.

## Goals / Non-Goals

**Goals:**
- One `flake.nix` input (`nixpkgs`, pinned) providing a devShell with the full
  toolchain, reproducible across four architectures.
- A `just` command surface every later epic reuses.
- `nix flake check` green from day one.

**Non-Goals:**
- Building the site (`packages.default`) — deferred to the Hugo-scaffold epic,
  which needs `hugo.toml` and content to exist first.
- CI wiring — that is the CI/CD epic.

## Decisions

- **Plain nix, no flake-utils.** A `forAllSystems = f: nixpkgs.lib.genAttrs
  supportedSystems (system: f { inherit system; pkgs = import nixpkgs { inherit
  system; }; })` helper maps outputs over an explicit `supportedSystems` list.
  This keeps the input graph minimal and makes architecture support legible.
- **nixpkgs pinned to `nixos-26.05`** (stable) — gives Hugo extended, a recent
  Node, lychee, just, jq, and yq-go without floating `unstable`.
- **Playwright browsers from `pkgs.playwright-driver.browsers`**, exported via
  `PLAYWRIGHT_BROWSERS_PATH` + `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1`, so the test
  epic never reaches the network for browser binaries — consistent with the
  no-runtime-third-party-calls ethos and hermetic CI.
- **`mkShellNoCC`** — no C compiler is needed for a static-site toolchain.
- **`yq-go` included** — the fetch/merge scripts read `data/curation.yaml`.
- **`formatter` output** (`nixpkgs-fmt`) so `nix flake check` has something to
  check before `packages.default` exists.

## Risks / Trade-offs

- Pinning to a stable nixpkgs may lag the very latest Hugo; acceptable and
  desirable for reproducibility. Bumping is a `flake.lock` update.
- `playwright-driver.browsers` version must match the `@playwright/test` npm
  version used by the test epic. Documented as a coupling to check when the test
  epic pins its npm dependency; mismatch surfaces as a Playwright launch error,
  caught by `just verify`.

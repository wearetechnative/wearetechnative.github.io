## Why

The entire site is required to build hermetically through a Nix flake — `nix
develop -c hugo --minify` must succeed with zero errors and `nix flake check`
must pass, with no global toolchain assumptions (brief §2.3). Every other epic
(data fetch, Hugo build, tests, CI) depends on a reproducible dev environment
existing first, so this is the foundation that must land before the project can
take off.

## What Changes

- Add `flake.nix` providing a devShell with the pinned toolchain the whole
  project needs: `hugo` (extended), `curl`, `jq`, `nodejs`, Playwright browsers,
  `lychee`, `just`, `yq-go`.
- Support four architectures — `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`,
  `aarch64-darwin` — using **plain nix** (a `forAllSystems` helper over an
  explicit systems list). **BREAKING for tooling choice:** flake-utils is
  explicitly not used.
- Pin every version via `flake.lock` (committed).
- Add `.envrc` (`use flake`) for optional direnv integration.
- Add a `justfile` with thin wrappers over `nix develop -c ...` (`dev`, `build`,
  `fetch`, `verify`).
- Add `.gitignore` covering `public/`, `data/repos.json`, node/Playwright and Nix
  artifacts.

## Capabilities

### New Capabilities
- `dev-environment`: The hermetic, multi-architecture Nix devShell and the `just`
  task interface that every build, fetch, and verify action runs through.

### Modified Capabilities
<!-- none — first change -->

## Impact

- New files: `flake.nix`, `flake.lock`, `.envrc`, `justfile`, `.gitignore`.
- Establishes the command surface (`just dev/build/fetch/verify`) that later
  epics extend. `packages.default` (the built site) is intentionally deferred to
  the Hugo-scaffold epic; this change ships the devShell and `flake check`
  passing.
- No runtime/browser impact — build-time only.

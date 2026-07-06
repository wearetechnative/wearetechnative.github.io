# dev-environment Specification

## Purpose
TBD - created by archiving change nix-flake-devenv. Update Purpose after archive.
## Requirements
### Requirement: Hermetic multi-architecture dev environment

The project SHALL provide a Nix flake devShell that supplies every tool needed to
fetch data, build, and verify the site, pinned via a committed `flake.lock`, with
no reliance on globally installed toolchains. It SHALL support `x86_64-linux`,
`aarch64-linux`, `x86_64-darwin`, and `aarch64-darwin` using plain nix (a
`forAllSystems` helper over an explicit systems list) and SHALL NOT use
flake-utils.

#### Scenario: devShell provides the pinned toolchain

- **WHEN** a developer runs `nix develop` on any supported system
- **THEN** `hugo` (extended), `curl`, `jq`, `node`, `lychee`, `just`, and `yq`
  are available on `PATH` at versions locked by `flake.lock`

#### Scenario: flake check passes

- **WHEN** `nix flake check` is run
- **THEN** it evaluates and passes with no errors

#### Scenario: no flake-utils dependency

- **WHEN** `flake.nix` is inspected
- **THEN** its only input is `nixpkgs` and architecture support is expressed with
  a plain-nix `forAllSystems` helper over an explicit `supportedSystems` list

#### Scenario: Playwright browsers come from Nix

- **WHEN** the devShell is entered
- **THEN** `PLAYWRIGHT_BROWSERS_PATH` points at the Nix-provided browsers and
  Playwright does not attempt its own browser download

### Requirement: just task interface

The project SHALL expose a `justfile` whose targets are thin wrappers over
`nix develop -c ...`, giving one command surface for every repeatable action.

#### Scenario: core targets exist

- **WHEN** `just --list` is run
- **THEN** it lists at least `dev`, `build`, `fetch`, and `verify`, each
  delegating to `nix develop -c ...`

### Requirement: correct version-control hygiene

The repository SHALL commit `flake.lock` and ignore generated artifacts.

#### Scenario: generated artifacts ignored

- **WHEN** `.gitignore` is inspected
- **THEN** it ignores `public/` and `data/repos.json`, while `flake.lock` remains
  tracked


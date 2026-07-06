---
# wearetechnative.github.io-j5rf
title: Nix flake & dev environment (hermetic build foundation)
status: completed
type: epic
priority: high
created_at: 2026-07-06T10:28:42Z
updated_at: 2026-07-06T10:35:32Z
parent: wearetechnative.github.io-lria
---

Establish the hermetic Nix-flake foundation everything else builds on. Plain nix for supported architectures (x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin) — NO flake-utils. devShell provides pinned hugo-extended, curl, jq, nodejs, playwright, lychee, just.

## Acceptance
- flake.nix uses plain nix (forAllSystems helper over a systems list), not flake-utils.
- `nix develop` provides all tooling; versions pinned via flake.lock.
- `nix flake check` passes on all supported systems.
- .envrc (use flake) for direnv.
- justfile with thin wrappers over `nix develop -c ...` (dev/build/fetch/verify).

OpenSpec change: 01-nix-flake-devenv

## Summary of Changes

Delivered the hermetic Nix-flake foundation (OpenSpec change `nix-flake-devenv`, archived as `2026-07-06-nix-flake-devenv`).

- `flake.nix`: single `nixpkgs` input (nixos-26.05), plain-nix `forAllSystems` over x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin. No flake-utils.
- devShell: hugo (extended v0.161.1), curl, jq, nodejs, playwright-driver.browsers, lychee, just, yq-go — all pinned via `flake.lock`.
- Playwright browsers sourced from Nix (no network download).
- `.envrc` (use flake), `justfile` (dev/build/fetch/verify), `.gitignore`.
- Verified: `nix flake check` passes; devShell resolves all tools; `just --list` shows the four targets.

Deferred to the Hugo-scaffold epic: `packages.default` (the built site), which needs `hugo.toml` + content first.

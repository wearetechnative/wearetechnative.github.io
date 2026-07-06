---
# wearetechnative.github.io-lria
title: 01 Alpha Base — Portfolio Site PoC
status: todo
type: milestone
priority: high
created_at: 2026-07-06T10:28:31Z
updated_at: 2026-07-06T10:28:31Z
---

First alpha-ready milestone for the wearetechnative open-source portfolio site (wearetechnative.github.io). A single, fast, filterable landing page rendering ~93 public repos via Hugo, hermetically built with Nix flakes, deployed to GitHub Pages. This milestone delivers a working, tested PoC that serves as the alpha base for later development.

## Scope
Everything required by BRIEF-wearetechnative-portfolio-site.md to satisfy the §10 acceptance criteria: hermetic Nix build, GitHub API data fetch + curation merge, the single landing page with client-side filtering, self-hosted brand assets, thorough e2e testing (Playwright), and the CI/CD deploy pipeline.

## Definition of Done
- `nix flake check` passes on all supported architectures.
- `nix develop -c hugo --minify --gc` builds `public/` with 0 errors, 0 warnings.
- Data fetch + curation merge produces correct categorised grid.
- Playwright e2e smoke suite passes headless (load, search, filter, category, dark-mode, no console errors, no non-GitHub network).
- Progressive enhancement: grid renders with JS disabled.
- CI deploy pipeline green; Pages settings documented.
- README lets an engineer add a project in under 5 minutes.

Child epics track each work area. Each epic is driven by an OpenSpec change (proposal → design → tasks) and implemented via /opsx:apply.

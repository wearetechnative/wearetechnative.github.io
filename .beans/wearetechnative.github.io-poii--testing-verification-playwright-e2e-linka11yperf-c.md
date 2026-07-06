---
# wearetechnative.github.io-poii
title: 'Testing & verification: Playwright e2e + link/a11y/perf checks'
status: completed
type: epic
priority: high
created_at: 2026-07-06T10:29:17Z
updated_at: 2026-07-06T13:45:23Z
parent: wearetechnative.github.io-lria
blocked_by:
    - wearetechnative.github.io-2ard
---

Prove the PoC works. Thorough e2e test cases wired into `just verify` and CI. This epic must demonstrate the §10 acceptance criteria pass.

## Acceptance
- tests/smoke.spec.ts (Playwright): page loads at /, grid ≥1 card; search 'terraform' reduces grid and every visible card matches; category chip toggle filters correctly; dark-mode toggle flips data-theme and persists across interaction; no console errors; NO network requests to non-GitHub origins at runtime.
- Progressive-enhancement test: grid renders with JS disabled.
- lychee link-check on public/ (no broken internal links; external may warn).
- Lighthouse budget documented: Performance ≥90, Accessibility ≥95, with command in README.
- `just verify` runs flake check + lychee + Playwright against locally-served public/.

OpenSpec change: testing-verification

## Summary of Changes

Delivered committed testing & verification (OpenSpec change testing-verification, archived 2026-07-06).

- tests/: Playwright project pinned to @playwright/test@1.59.1 (matches the flake driver); package-lock committed; tiny dependency-free static server (serve.mjs); playwright.config.ts (chromium, headless, webServer serving public/).
- tests/smoke.spec.ts (7 tests): load+grid, search narrows + every visible card matches + clear restores, category chip + aria-pressed, dark toggle flips data-theme + persists, no console errors + network-origin allow-list (GitHub + umami only), no-results message, and a JS-disabled progressive-enhancement test.
- .lychee.toml + `just linkcheck` with --root-dir (resolves root-relative /fonts,/img,/css).
- justfile: test-install/test/linkcheck/lighthouse targets; verify = build + flake check + linkcheck + Playwright.
- README: Lighthouse budget (Perf >=90, A11y >=95) + command.

Verified: `just verify` passes end to end — nix flake check OK; lychee 107/107 links OK, 0 errors; Playwright 7/7 passed. Hermetic: browsers from the flake, no download.

---
# wearetechnative.github.io-poii
title: 'Testing & verification: Playwright e2e + link/a11y/perf checks'
status: todo
type: epic
priority: high
created_at: 2026-07-06T10:29:17Z
updated_at: 2026-07-06T10:29:27Z
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

OpenSpec change: 06-testing-verification

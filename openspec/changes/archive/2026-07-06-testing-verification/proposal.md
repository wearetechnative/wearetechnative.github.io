## Why

The PoC is only "done" when it is provably working. This epic delivers the
thorough e2e test cases and the link/a11y/perf checks that demonstrate the brief
§10 acceptance criteria pass, wired into `just verify` and reused by CI.

## What Changes

- Add `tests/` as a small Node project (Playwright) pinned to match the
  `playwright-driver.browsers` version from the flake. `tests/smoke.spec.ts`
  covers, headless against a locally-served `public/`:
  - page loads at `/`, grid renders ≥ 1 card;
  - typing "terraform" in search reduces the grid and **every** visible card
    matches;
  - toggling a category chip filters correctly;
  - dark-mode toggle flips `data-theme` and persists across interaction
    (in-memory);
  - **no console errors**;
  - **no network requests to non-GitHub origins** at runtime — allow-list GitHub
    origins and `umami.pimsnel.com` (the approved analytics exception); fail on
    anything else.
- Add a progressive-enhancement test: grid renders with JavaScript disabled.
- Wire `lychee` link-check of `public/` (no broken internal links; external may
  warn).
- Document the Lighthouse budget command (Performance ≥ 90, Accessibility ≥ 95)
  in the README.
- Make `just verify` run `nix flake check` + `lychee` + Playwright against a
  served `public/`.

## Capabilities

### New Capabilities
- `verification`: The e2e smoke suite, progressive-enhancement check,
  link-checking, and the performance/accessibility budget that gate a release.

## Impact

- New: `tests/**` (Playwright project, `smoke.spec.ts`), README Lighthouse note;
  `just verify` finalised.
- Depends on: `client-filtering` (drives the interactions), `site-shell`
  (Playwright browsers from Nix). Blocks: `ci-cd-deploy` (gate before deploy).
- Constraint: hermetic — Playwright browsers come from the flake, not a download.
